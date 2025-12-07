import 'package:ephor/data/repositories/form/abstract_form_repository.dart';
import 'package:ephor/data/services/supabase/supabase_service.dart';
import 'package:ephor/domain/models/form_editor/form_model.dart';
import 'package:ephor/utils/results.dart';
import 'package:ephor/utils/custom_message_exception.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FormRepository extends AbstractFormRepository {
  final SupabaseService _supabaseService;

  FormRepository({required SupabaseService supabaseService})
    : _supabaseService = supabaseService;

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

  // @override
  // Future<Result<List<FormModel>>> getFormsByCreator(String creatorId) async {
  //   try {
  //     await Future.delayed(const Duration(milliseconds: 500));

  //     final forms = _formsStorage.values
  //         .where((form) => form.createdBy == creatorId)
  //         .toList();

  //     // Sort by updatedAt descending (most recent first)
  //     forms.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  //     return Result.ok(forms);
  //   } catch (e) {
  //     return Result.error(
  //       CustomMessageException('Failed to fetch forms: ${e.toString()}'),
  //     );
  //   }
  // }

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
      await _supabaseService.insertCatnaAssessment(payload);
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
}
