import 'package:ephor/domain/models/form_editor/form_model.dart';
import 'package:ephor/utils/results.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AbstractFormRepository extends ChangeNotifier {
  Future<Result<FormModel>> saveForm(FormModel form);
  Future<Result<FormModel?>> getFormById(String formId);
  Future<Result<List<FormModel>>> getAllForms();
  Future<Result<void>> deleteForm(String formId);
  Future<Result<void>> submitCatna(Map<String, dynamic> payload);
  Future<Result<PostgrestMap>> fetchActiveCatnaForm();
  Future<Result<PostgrestMap>> fetchActiveImpactAssessmentForm();
  Future<Result<void>> submitImpactAssessment(Map<String, dynamic> payload);
}

