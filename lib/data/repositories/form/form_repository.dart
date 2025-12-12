import 'dart:async';
import 'dart:convert';

import 'package:ephor/data/repositories/form/abstract_form_repository.dart';
import 'package:ephor/data/services/model_api/model_api_service.dart';
import 'package:ephor/data/services/supabase/supabase_service.dart';
import 'package:ephor/domain/models/form_editor/form_model.dart';
import 'package:ephor/domain/models/overview/activity_model.dart';
import 'package:ephor/domain/use_cases/excel_generator.dart';
import 'package:ephor/domain/use_cases/payload_to_api_model.dart';
import 'package:ephor/utils/results.dart';
import 'package:ephor/utils/custom_message_exception.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FormRepository extends AbstractFormRepository {
  final SupabaseService _supabaseService;
  final ModelAPIService _modelAPIService;

  final ValueNotifier<bool> isAnalysisRunning = ValueNotifier(false);

  FormRepository({
    required SupabaseService supabaseService,
    required ModelAPIService modelAPIService
  })
    : _supabaseService = supabaseService,
      _modelAPIService = modelAPIService;

  @override
  Future<Result<FormModel>> saveForm(FormModel form) async {
    try {
      final formId = form.id;
      final formData = form.toJson();

      if (formId.isEmpty) {
        formData.remove('id');
        formData['created_at'] = DateTime.now().toIso8601String();
      }
      
      formData['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabaseService.upsertForm(formData);

      return Result.ok(FormModel.fromJson(response));
    } catch (e) {
      return Result.error(
        CustomMessageException('Failed to save form: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<FormModel?>> getFormById(String formId) async {
    try {
      final response = await _supabaseService.getFormById(formId);

      if (response == null) {
        return Result.error(
          CustomMessageException('Form not found with ID: $formId'),
        );
      }

      return Result.ok(FormModel.fromJson(response));
    } catch (e) {
      return Result.error(
        CustomMessageException('Failed to fetch form: $e'),
      );
    }
  }

  @override
  Future<Result<List<FormModel>>> getAllForms() async {
    try {
      final List<Map<String, dynamic>> response = await _supabaseService.getAllForms();
      final forms = response.map((json) => FormModel.fromJson(json)).toList();

      return Result.ok(forms);
    } catch (e) {
      return Result.error(
        CustomMessageException('Failed to fetch forms: $e'),
      );
    }
  }

  @override
  Future<Result<void>> deleteForm(String formId) async {
    try {
      // Determine if we need to delete responses first (Cascade)
      // If your Supabase/Postgres Foreign Key is set to "ON DELETE CASCADE",
      // you only need to delete the form. 
      // If not, you must delete responses manually first.
      // Assuming ON DELETE CASCADE is set up in DB:
      await _supabaseService.deleteForm(formId);

      return Result.ok(null);
    } on PostgrestException catch (e) {
      return Result.error(
        CustomMessageException('Database error deleting form: ${e.message}'),
      );
    } catch (e) {
      return Result.error(
        CustomMessageException('Failed to delete form: $e'),
      );
    }
  }
  
  @override
  Future<Result<PostgrestMap>> fetchActiveCatnaForm() async {
    final result = await _supabaseService.fetchActiveCatnaForm();

    if (result != null) {
      return Result.ok(result);
    }

    return Result.error(CustomMessageException("Can't fetch active CATNA form"));
  }

  @override
  Future<Result<PostgrestMap>> fetchActiveImpactAssessmentForm() async {
    final result = await _supabaseService.fetchActiveImpactAssessmentForm();

    if (result != null) {
      return Result.ok(result);
    }

    return Result.error(CustomMessageException("Can't fetch active Impact Assessment form"));
  }
  
  @override
  Future<Result<void>> submitCatna(Map<String, dynamic> payload) async {
    try {
      String employeeName = payload.remove('updated_user');
      await _supabaseService.insertCatnaAssessment(payload);
      await _supabaseService.updateEmployeeCATNAStatus(employeeName);
      _triggerAnalysisInBackground(payload);
      return const Result.ok(null);
    } catch (e) {
      return Result.error(
        CustomMessageException('Failed to submit CATNA assessment: $e'),
      );
    }
  }

  @override
  Future<Result<void>> submitImpactAssessment(Map<String, dynamic> payload) async {
    try {
      await _supabaseService.insertImpactAssessment(payload);
      return const Result.ok(null);
    } catch (e) {
      return Result.error(
        CustomMessageException('Failed to submit Impact assessment: $e'),
      );
    }
  }

  Future<Result<Map<String, dynamic>>> analyzeCATNA(List<Map<String, dynamic>> jsonData) async {
    try {
      // 1. Convert JSON to Excel Bytes in Memory
      final List<int>? excelBytes = ExcelGenerator.generateExcelBytes(jsonData);
      
      if (excelBytes == null || excelBytes.isEmpty) {
        return Result.error(CustomMessageException('No data available to generate Excel file.'));
      }

      // 2. Upload the Bytes (Mocking a filename is required by most APIs)
      final response = await _modelAPIService.analyzeDatasetBytes(
        excelBytes, 
        'catna_submission.xlsx' 
      );
      
      final responseBody = response.body;

      // 3. Handle Response
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(responseBody);
        return Result.ok(data);
      } else {
        // Try to parse server error message
        String errorMessage = 'Request failed with status: ${response.statusCode}';
        try {
          final errorJson = json.decode(responseBody);
          if (errorJson['detail'] != null) {
            errorMessage = errorJson['detail'];
          }
        } catch (_) {}
        
        return Result.error(CustomMessageException(errorMessage));
      }
    } catch (e) {
      return Result.error(CustomMessageException('Analysis failed: $e'));
    }
  }
  
  Future<void> _triggerAnalysisInBackground(Map<String, dynamic> currentPayload) async {
    try { 
      // Notify listeners analysis started
      isAnalysisRunning.value = true;
      
      final response = await _supabaseService.getAllFinishedCATNA();
      final List<dynamic> allAssessments = response;
      final List<Map<String, dynamic>> fullDataset = [];

      for (var assessment in allAssessments) {
        final assessmentMap = Map<String, dynamic>.from(assessment as Map);
        final rows = convertPayloadToAPIModel(assessmentMap);
        fullDataset.addAll(rows);
      }
      
      final analysisResult = await analyzeCATNA(fullDataset);
      print(analysisResult);

      if (analysisResult case Ok(value: Map<String, dynamic> result)) {
        // FIX: Ensure this doesn't crash if result is malformed
        await _supabaseService.updateOverviewStatistics(result);
      } else if (analysisResult case Error _) {
        throw CustomMessageException("Cannot analyze CATNA");
      }

      print("General Overview updated successfully.");
      
    } catch (e) {
      print("Background analysis failed: $e");
      // Optionally log to Crashlytics here
    } finally {
      // CHANGE 2: "finally" ensures this ALWAYS runs, even if there is an error
      isAnalysisRunning.value = false;
    }
  }

  Stream<Map<String, dynamic>> getOverviewStatsStream() {
    return _supabaseService.getOverviewStatsStream(convertFunction);
  }

  Future<Result<Map<String, dynamic>>> getOverviewStats() async {
    try {
      final result = await _supabaseService.getOverviewStats();
      final List<Map<String, dynamic>> typedList = List<Map<String, dynamic>>.from(result);

      return Result.ok(convertFunction(typedList));
    } on Error {
      return Result.error(CustomMessageException("Can't load overview stats"));
    }
  }

  Map<String, dynamic> convertFunction(List<Map<String, dynamic>> event) {
    // 1. Handle Empty Case
    if (event.isEmpty) {
      return {
        'training_needs_count': 0,
        'recent_activity': <ActivityModel>[],
        'gemini_insights': 'None',
        'updated_at': DateFormat('MM/dd/yyyy hh:mm:ss a').format(DateTime.now()),
        'full_report': 'N/A'
      };
    }

    final row = event.first;

    // 2. Deserialize Activity List
    final List<dynamic> rawActivityList = row['recent_activity'] ?? [];
    final List<ActivityModel> activities = rawActivityList
        .map((json) => ActivityModel.fromJson(json as Map<String, dynamic>))
        .toList();

    // 3. Return Final Map
    return {
      'training_needs_count': row['training_needs_count'] ?? 0,
      'recent_activity': activities,
      'gemini_insights': row['full_report']['gemini_insights'],
      'updated_at': row['updated_at'],
      'full_report': row['full_report']['catna_analysis_summary']
    };
  }
}
