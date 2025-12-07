import 'package:ephor/data/repositories/form/abstract_form_repository.dart';
import 'package:ephor/data/services/supabase/supabase_service.dart';
import 'package:ephor/domain/models/form_creator/form_model.dart';
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

      formData['created_by'] = SupabaseService.auth.currentUser?.id;

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
  Future<Result<FormModel>> publishForm(String formId) async {
    try {
      final response = await _supabaseService.publishForm(formId);

      return Result.ok(FormModel.fromJson(response));
    } on PostgrestException catch (e) {
      return Result.error(
        CustomMessageException('Database error publishing form: ${e.message}'),
      );
    } catch (e) {
      return Result.error(
        CustomMessageException('Failed to publish form: $e'),
      );
    }
  }

  @override
  Future<Result<FormModel>> unpublishForm(String formId) async {
    try {
      // 1. Fetch the form first to check constraints
      final formResult = await getFormById(formId);
      FormModel? form;
      
      if (formResult case Error(error: CustomMessageException exception)) {
        return Result.error(exception);
      } else if (formResult case Ok(value: FormModel formModel)) {
        form = formModel;
      }

      if (form!.responseCount > 0) {
        return Result.error(
          CustomMessageException(
            'Cannot unpublish form with ${form.responseCount} existing responses. '
            'Please archive the form instead.',
          ),
        );
      }

      // 3. Update status
      final response = await _supabaseService.unpublishForm(formId);

      return Result.ok(FormModel.fromJson(response));
    } catch (e) {
      return Result.error(
        CustomMessageException('Failed to unpublish form: $e'),
      );
    }
  }

  // @override
  // Future<Result<FormResponseSummary>> getFormResponseSummary(
  //   String formId,
  // ) async {
  //   try {
  //     await Future.delayed(const Duration(milliseconds: 300));

  //     // For mock, return empty summary or cached one
  //     if (_responseSummaries.containsKey(formId)) {
  //       return Result.ok(_responseSummaries[formId]!);
  //     }

  //     final summary = FormResponseSummary(
  //       formId: formId,
  //       totalResponses: 0,
  //       lastResponseAt: null,
  //       responsesByDate: {},
  //     );

  //     _responseSummaries[formId] = summary;
  //     return Result.ok(summary);
  //   } catch (e) {
  //     return Result.error(
  //       CustomMessageException('Failed to fetch responses: ${e.toString()}'),
  //     );
  //   }
  // }

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
}
