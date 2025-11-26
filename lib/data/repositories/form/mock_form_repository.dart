// data/repositories/form/mock_form_repository.dart

import 'package:ephor/data/repositories/form/abstract_form_repository.dart';
import 'package:ephor/domain/models/form/form_model.dart';
import 'package:ephor/domain/models/form/form_enums.dart';
import 'package:ephor/domain/models/form/form_response_summary.dart';
import 'package:ephor/utils/results.dart';
import 'package:ephor/utils/custom_message_exception.dart';
import 'package:uuid/uuid.dart';

/// Mock implementation for development and testing.
///
/// Uses in-memory storage. Data will be lost on app restart.
class MockFormRepository implements IFormRepository {
  // In-memory storage
  final Map<String, FormModel> _formsStorage = {};
  final Map<String, FormResponseSummary> _responseSummaries = {};

  // UUID generator
  final _uuid = const Uuid();

  @override
  Future<Result<FormModel>> saveForm(FormModel form) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));

      // Generate UUID if new form (id is empty)
      final formId = form.id.isEmpty ? _uuid.v4() : form.id;

      final savedForm = form.copyWith(
        id: formId,
        updatedAt: DateTime.now(),
        // If creating new form, set createdAt
        createdAt: form.id.isEmpty ? DateTime.now() : form.createdAt,
      );

      _formsStorage[formId] = savedForm;

      return Result.ok(savedForm);
    } catch (e) {
      return Result.error(
        CustomMessageException('Failed to save form: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<FormModel>> publishForm(String formId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final form = _formsStorage[formId];
      if (form == null) {
        return Result.error(CustomMessageException('Form not found'));
      }

      final publishedForm = form.copyWith(
        status: FormStatus.published,
        updatedAt: DateTime.now(),
        
        //responseCount: 5, 
      );

      _formsStorage[formId] = publishedForm;
      return Result.ok(publishedForm);
    } catch (e) {
      return Result.error(
        CustomMessageException('Failed to publish form: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<FormModel>> unpublishForm(String formId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final form = _formsStorage[formId];
      if (form == null) {
        return Result.error(CustomMessageException('Form not found'));
      }

      // Constraint: Cannot unpublish if form has responses
      if (form.responseCount > 0) {
        return Result.error(
          CustomMessageException(
            'Cannot unpublish form with ${form.responseCount} existing responses. '
            'Please archive the form instead.',
          ),
        );
      }

      final unpublishedForm = form.copyWith(
        status: FormStatus.draft,
        updatedAt: DateTime.now(),
      );

      _formsStorage[formId] = unpublishedForm;
      return Result.ok(unpublishedForm);
    } catch (e) {
      return Result.error(
        CustomMessageException('Failed to unpublish form: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<FormResponseSummary>> getFormResponseSummary(
    String formId,
  ) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      // For mock, return empty summary or cached one
      if (_responseSummaries.containsKey(formId)) {
        return Result.ok(_responseSummaries[formId]!);
      }

      final summary = FormResponseSummary(
        formId: formId,
        totalResponses: 0,
        lastResponseAt: null,
        responsesByDate: {},
      );

      _responseSummaries[formId] = summary;
      return Result.ok(summary);
    } catch (e) {
      return Result.error(
        CustomMessageException('Failed to fetch responses: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<FormModel?>> getFormById(String formId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      return Result.ok(_formsStorage[formId]);
    } catch (e) {
      return Result.error(
        CustomMessageException('Failed to fetch form: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<List<FormModel>>> getFormsByCreator(String creatorId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final forms = _formsStorage.values
          .where((form) => form.createdBy == creatorId)
          .toList();

      // Sort by updatedAt descending (most recent first)
      forms.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      return Result.ok(forms);
    } catch (e) {
      return Result.error(
        CustomMessageException('Failed to fetch forms: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<void>> deleteForm(String formId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      if (!_formsStorage.containsKey(formId)) {
        return Result.error(CustomMessageException('Form not found'));
      }

      _formsStorage.remove(formId);
      _responseSummaries.remove(formId);

      return Result.ok(null);
    } catch (e) {
      return Result.error(
        CustomMessageException('Failed to delete form: ${e.toString()}'),
      );
    }
  }
}
