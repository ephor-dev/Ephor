// ui/my_forms/view_model/my_forms_view_model.dart

import 'package:flutter/foundation.dart';
import 'package:ephor/data/repositories/form/abstract_form_repository.dart';
import 'package:ephor/domain/models/form_creator/form_model.dart';
import 'package:ephor/utils/results.dart';

/// ViewModel for My Forms screen.
/// 
/// Manages the list of all forms (drafts + published) and provides
/// actions for each form (edit, view responses, delete).
class MyFormsViewModel extends ChangeNotifier {
  final IFormRepository _formRepository;
  
  // State
  List<FormModel> _forms = [];
  bool _isLoading = false;
  String? _error;
  
  // Getters
  List<FormModel> get forms => _forms;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;
  bool get hasForms => _forms.isNotEmpty;
  
  // Filtered lists
  List<FormModel> get draftForms => _forms.where((f) => f.isDraft).toList();
  List<FormModel> get publishedForms => _forms.where((f) => f.isPublished).toList();
  
  MyFormsViewModel({required IFormRepository formRepository})
      : _formRepository = formRepository;
  
  // ============================================
  // LOAD FORMS
  // ============================================
  
  /// Loads all forms from the repository.
  Future<void> loadForms() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final result = await _formRepository.getAllForms();
      
      switch (result) {
        case Ok<List<FormModel>>(:final value):
          _forms = value;
          _error = null;
          
        case Error<List<FormModel>>(:final error):
          _error = error.toString();
      }
    } catch (e) {
      _error = 'Unexpected error: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // ============================================
  // DELETE FORM
  // ============================================
  
  /// Deletes a form by ID.
  /// Returns true if successful, false otherwise.
  Future<Result<void>> deleteForm(String formId) async {
    try {
      final result = await _formRepository.deleteForm(formId);
      
      switch (result) {
        case Ok<void>():
          // Remove from local list
          _forms.removeWhere((form) => form.id == formId);
          notifyListeners();
          return Result.ok(null);
          
        case Error<void>(:final error):
          return Result.error(error);
      }
    } catch (e) {
      return Result.error(
        Exception('Failed to delete form: ${e.toString()}'),
      );
    }
  }
  
  // ============================================
  // HELPER METHODS
  // ============================================
  
  /// Gets a form by ID from the cached list.
  FormModel? getFormById(String formId) {
    try {
      return _forms.firstWhere((form) => form.id == formId);
    } catch (e) {
      return null;
    }
  }
  
  /// Refreshes the forms list.
  Future<void> refresh() => loadForms();
}

