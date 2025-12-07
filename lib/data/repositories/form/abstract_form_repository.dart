import 'package:ephor/domain/models/form_creator/form_model.dart';
import 'package:ephor/utils/results.dart';
import 'package:flutter/material.dart';

abstract class AbstractFormRepository extends ChangeNotifier {
  Future<Result<FormModel>> saveForm(FormModel form);
  Future<Result<FormModel>> publishForm(String formId);
  Future<Result<FormModel>> unpublishForm(String formId);
  // Future<Result<FormResponseSummary>> getFormResponseSummary(String formId);
  Future<Result<FormModel?>> getFormById(String formId);
  // Future<Result<List<FormModel>>> getFormsByCreator(String creatorId);
  Future<Result<List<FormModel>>> getAllForms();
  Future<Result<void>> deleteForm(String formId);
}

