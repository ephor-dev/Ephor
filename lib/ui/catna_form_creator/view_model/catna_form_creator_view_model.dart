import 'package:flutter/material.dart';
import 'package:ephor/data/repositories/form/abstract_form_repository.dart';
import 'package:ephor/domain/models/form/form_model.dart';
import 'package:ephor/domain/models/form/section_model.dart';
import 'package:ephor/domain/models/form/question_model.dart';
import 'package:ephor/domain/models/form/form_enums.dart';
import 'package:ephor/utils/results.dart';
import 'package:ephor/utils/custom_message_exception.dart';

class CatnaFormCreatorViewModel extends ChangeNotifier {
  // ============================================
  // DEPENDENCIES
  // ============================================
  final IFormRepository _formRepository;
  
  CatnaFormCreatorViewModel({
    required IFormRepository formRepository,
  }) : _formRepository = formRepository {
    _initializeForm();
  }
  
  // ============================================
  // STATE - Form Data
  // ============================================
  FormModel? _currentForm;
  FormModel? get currentForm => _currentForm;
  
  String get formId => _currentForm?.id ?? '';
  
  // Form controllers
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  
  // List to hold form sections with questions (for UI compatibility)
  final List<Map<String, dynamic>> _sections = [];
  List<Map<String, dynamic>> get sections => _sections;
  
  // Question type options
  final List<String> questionTypes = [
    'Text',
    'Multiple Choice',
    'Checkbox',
    'Rating Scale',
    'Date',
    'File Upload',
  ];
  
  // ============================================
  // STATE - Loading & Errors
  // ============================================
  
  // Operation states
  bool _isSaving = false;
  bool get isSaving => _isSaving;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  // Error state
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  
  // Status flags
  FormStatus _formStatus = FormStatus.draft;
  FormStatus get formStatus => _formStatus;
  
  bool _isPublished = false;
  bool get isPublished => _isPublished;
  
  void _initializeForm() {
    // Start with one default section
    addSection();
  }
  
  void addSection() {
    _sections.add({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': 'Section ${_sections.length + 1}',
      'description': '',
      'questions': <Map<String, dynamic>>[],
    });
    notifyListeners();
  }
  
  void removeSection(int sectionIndex) {
    if (sectionIndex >= 0 && sectionIndex < _sections.length && _sections.length > 1) {
      _sections.removeAt(sectionIndex);
      notifyListeners();
    }
  }
  
  void updateSectionTitle(int sectionIndex, String title) {
    if (sectionIndex >= 0 && sectionIndex < _sections.length) {
      _sections[sectionIndex]['title'] = title;
      notifyListeners();
    }
  }
  
  void updateSectionDescription(int sectionIndex, String description) {
    if (sectionIndex >= 0 && sectionIndex < _sections.length) {
      _sections[sectionIndex]['description'] = description;
      notifyListeners();
    }
  }
  
  void addQuestion(int sectionIndex, String questionType) {
    if (sectionIndex >= 0 && sectionIndex < _sections.length) {
      final questions = _sections[sectionIndex]['questions'] as List<Map<String, dynamic>>;
      questions.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'type': questionType,
        'question': '',
        'required': false,
        'options': (questionType == 'Multiple Choice' || questionType == 'Checkbox') 
            ? ['Option 1', 'Option 2'] 
            : null,
      });
      notifyListeners();
    }
  }
  
  void removeQuestion(int sectionIndex, int questionIndex) {
    if (sectionIndex >= 0 && sectionIndex < _sections.length) {
      final questions = _sections[sectionIndex]['questions'] as List<Map<String, dynamic>>;
      if (questionIndex >= 0 && questionIndex < questions.length) {
        questions.removeAt(questionIndex);
        notifyListeners();
      }
    }
  }
  
  void updateQuestion(int sectionIndex, int questionIndex, String question) {
    if (sectionIndex >= 0 && sectionIndex < _sections.length) {
      final questions = _sections[sectionIndex]['questions'] as List<Map<String, dynamic>>;
      if (questionIndex >= 0 && questionIndex < questions.length) {
        questions[questionIndex]['question'] = question;
        notifyListeners();
      }
    }
  }
  
  void updateQuestionType(int sectionIndex, int questionIndex, String type) {
    if (sectionIndex >= 0 && sectionIndex < _sections.length) {
      final questions = _sections[sectionIndex]['questions'] as List<Map<String, dynamic>>;
      if (questionIndex >= 0 && questionIndex < questions.length) {
        questions[questionIndex]['type'] = type;
        // Add options for multiple choice and checkbox
        if (type == 'Multiple Choice' || type == 'Checkbox') {
          questions[questionIndex]['options'] = ['Option 1', 'Option 2'];
        } else {
          questions[questionIndex]['options'] = null;
        }
        notifyListeners();
      }
    }
  }
  
  void toggleQuestionRequired(int sectionIndex, int questionIndex) {
    if (sectionIndex >= 0 && sectionIndex < _sections.length) {
      final questions = _sections[sectionIndex]['questions'] as List<Map<String, dynamic>>;
      if (questionIndex >= 0 && questionIndex < questions.length) {
        questions[questionIndex]['required'] = !(questions[questionIndex]['required'] ?? false);
        notifyListeners();
      }
    }
  }
  
  // ============================================
  // SAVE FORM - Core Function
  // ============================================
  
  /// Saves the current form state to repository.
  /// Returns `Result<FormModel>` for handling in the View.
  Future<Result<FormModel>> saveForm() async {
    _isSaving = true;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // Build FormModel from current state
      final formToSave = _buildFormModelFromState();
      
      // Call repository
      final result = await _formRepository.saveForm(formToSave);
      
      // Handle result
      switch (result) {
        case Ok<FormModel>(:final value):
          // Update local state with saved form (including new ID)
          _currentForm = value;
          _formStatus = value.status;
          _isPublished = value.isPublished;
          
          _isSaving = false;
          _isLoading = false;
          notifyListeners();
          return Result.ok(value);
          
        case Error<FormModel>(:final error):
          _errorMessage = error.toString();
          _isSaving = false;
          _isLoading = false;
          notifyListeners();
          return Result.error(error);
      }
    } catch (e) {
      _errorMessage = 'Unexpected error: ${e.toString()}';
      _isSaving = false;
      _isLoading = false;
      notifyListeners();
      return Result.error(
        CustomMessageException(_errorMessage!)
      );
    }
  }
  
  // ============================================
  // HELPER METHOD - Build FormModel from State
  // ============================================
  
  /// Converts current UI state to FormModel.
  /// This gathers data from text controllers and sections list.
  FormModel _buildFormModelFromState() {
    // Convert Map-based sections to SectionModel list
    final sectionModels = _sections.asMap().entries.map((entry) {
      final index = entry.key;
      final sectionMap = entry.value;
      
      final questionMaps = sectionMap['questions'] as List<Map<String, dynamic>>;
      final questionModels = questionMaps.asMap().entries.map((qEntry) {
        final qIndex = qEntry.key;
        final qMap = qEntry.value;
        
        return QuestionModel(
          id: qMap['id'] as String? ?? '',
          questionText: qMap['question'] as String? ?? '',
          type: _parseQuestionType(qMap['type'] as String),
          isRequired: qMap['required'] as bool? ?? false,
          options: qMap['options'] != null 
              ? List<String>.from(qMap['options'] as List)
              : null,
          orderIndex: qIndex,
        );
      }).toList();
      
      return SectionModel(
        id: sectionMap['id'] as String? ?? '',
        title: sectionMap['title'] as String? ?? '',
        description: sectionMap['description'] as String? ?? '',
        questions: questionModels,
        orderIndex: index,
      );
    }).toList();
    
    return FormModel(
      id: _currentForm?.id,  // Preserve existing ID if updating
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      status: _formStatus,
      sections: sectionModels,
      createdAt: _currentForm?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      createdBy: 'current_user_id',  // TODO: Get from auth service
      responseCount: _currentForm?.responseCount ?? 0,
    );
  }
  
  /// Parse question type string to enum.
  QuestionType _parseQuestionType(String typeStr) {
    switch (typeStr) {
      case 'Text':
        return QuestionType.text;
      case 'Multiple Choice':
        return QuestionType.multipleChoice;
      case 'Checkbox':
        return QuestionType.checkbox;
      case 'Rating Scale':
        return QuestionType.ratingScale;
      case 'Date':
        return QuestionType.date;
      case 'File Upload':
        return QuestionType.fileUpload;
      default:
        return QuestionType.text;
    }
  }
  
  void togglePublish() {
    _isPublished = !_isPublished;
    notifyListeners();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}
