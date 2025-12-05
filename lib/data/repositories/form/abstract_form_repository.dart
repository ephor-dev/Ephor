// data/repositories/form/abstract_form_repository.dart

import 'package:ephor/domain/models/form_creator/form_model.dart';
import 'package:ephor/domain/models/form_creator/form_response_summary.dart';
import 'package:ephor/utils/results.dart';

/// Abstract interface for form data operations.
/// 
/// This allows us to:
/// 1. Use mock data during development
/// 2. Swap in Supabase later without changing ViewModel
/// 3. Easily test with mock implementations
abstract interface class IFormRepository {
  
  // ============================================
  // SAVE FORM - Core persistence operation
  // ============================================
  
  /// Saves a form (create new or update existing).
  /// 
  /// - If form.id is empty → creates new form
  /// - If form.id exists → updates existing form
  /// 
  /// Returns the saved FormModel with populated ID.
  Future<Result<FormModel>> saveForm(FormModel form);
  
  // ============================================
  // PUBLISH FORM - Status change operation
  // ============================================
  
  /// Changes form status to 'published'.
  /// 
  /// Business Rules (validated in ViewModel before calling):
  /// - Form must have a title
  /// - Form must have at least one section
  /// - At least one section must have questions
  /// 
  /// Returns updated FormModel with status = published.
  Future<Result<FormModel>> publishForm(String formId);
  
  /// Changes form status to 'draft' (unpublish).
  /// 
  /// Note: Cannot unpublish if form has responses.
  /// This validation happens in ViewModel.
  Future<Result<FormModel>> unpublishForm(String formId);
  
  // ============================================
  // VIEW RESPONSES - Fetch operation
  // ============================================
  
  /// Fetches response summary for a form.
  /// 
  /// Used to display response count and navigate to analytics.
  Future<Result<FormResponseSummary>> getFormResponseSummary(String formId);
  
  // ============================================
  // FORM MANAGEMENT - CRUD operations
  // ============================================
  
  /// Fetches a single form by ID.
  Future<Result<FormModel?>> getFormById(String formId);
  
  /// Fetches all forms created by a user.
  Future<Result<List<FormModel>>> getFormsByCreator(String creatorId);
  
  /// Fetches all forms (for mock/development - returns all forms in storage).
  /// In production with Supabase, this should filter by current user.
  Future<Result<List<FormModel>>> getAllForms();
  
  /// Deletes a form.
  /// Note: Should validate in ViewModel if form has responses.
  Future<Result<void>> deleteForm(String formId);
}

