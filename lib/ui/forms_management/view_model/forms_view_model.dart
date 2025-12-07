import 'package:ephor/data/repositories/form/form_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:ephor/domain/models/form_editor/form_model.dart';
import 'package:ephor/utils/results.dart';

class FormsViewModel extends ChangeNotifier {
  final FormRepository _formRepository;
  
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
  
  FormsViewModel({required FormRepository formRepository})
      : _formRepository = formRepository;

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

  FormModel? getFormById(String formId) {
    try {
      return _forms.firstWhere((form) => form.id == formId);
    } catch (e) {
      return null;
    }
  }
}

