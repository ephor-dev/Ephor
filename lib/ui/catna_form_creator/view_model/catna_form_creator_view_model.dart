import 'package:flutter/material.dart';
import 'package:ephor/data/repositories/form/abstract_form_repository.dart';
import 'package:ephor/data/repositories/auth/abstract_auth_repository.dart';
import 'package:ephor/domain/models/form_creator/form_model.dart';
import 'package:ephor/domain/models/form_creator/section_model.dart';
import 'package:ephor/domain/models/form_creator/question_model.dart';
import 'package:ephor/domain/models/form_creator/form_enums.dart';
import 'package:ephor/utils/results.dart';
import 'package:ephor/utils/custom_message_exception.dart';

class CatnaFormCreatorViewModel extends ChangeNotifier {
  final IFormRepository _formRepository;
  final AbstractAuthRepository _authRepository;
  final String? _formIdToLoad;
  
  CatnaFormCreatorViewModel({
    required IFormRepository formRepository,
    required AbstractAuthRepository authRepository,
    String? formIdToLoad,
  }) : _formRepository = formRepository,
       _authRepository = authRepository,
       _formIdToLoad = formIdToLoad {
    _initializeForm();
  }
  
  FormModel? _currentForm;
  FormModel? get currentForm => _currentForm;
  
  String get formId => _currentForm?.id ?? '';

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

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
  
  bool _isPublishing = false;
  bool get isPublishing => _isPublishing;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  // Error state
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  
  String? _validationError;
  String? get validationError => _validationError;
  
  // Status flags
  FormStatus _formStatus = FormStatus.draft;
  FormStatus get formStatus => _formStatus;
  
  bool _isPublished = false;
  bool get isPublished => _isPublished;
  
  void _initializeForm() {
    if (_formIdToLoad != null) {
      // Load existing form
      loadForm(_formIdToLoad);
    } else {
      // Start with one default section for a new form
      addSection();
    }
  }
  
  /// Load an existing form by ID for editing
  Future<void> loadForm(String formId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final result = await _formRepository.getFormById(formId);
      
      switch (result) {
        case Ok<FormModel?>(:final value):
          // Check if value is null (form not found)
          if (value == null) {
            _errorMessage = 'Form not found with ID: $formId';
            _isLoading = false;
            addSection(); // Create default section
            notifyListeners();
            return;
          }
          
          final form = value;
          _currentForm = form;
          
          // Populate form fields
          titleController.text = form.title;
          descriptionController.text = form.description;
          
          // Clear existing sections
          _sections.clear();
          
          // Convert FormModel sections to UI sections format
          for (final section in form.sections) {
            final uiSection = {
              'id': section.id,
              'title': section.title,
              'description': section.description,
              'questions': <Map<String, dynamic>>[],
            };
            
            // Convert questions
            for (final question in section.questions) {
              final uiQuestion = _convertQuestionToUI(question);
              (uiSection['questions'] as List<Map<String, dynamic>>).add(uiQuestion);
            }
            
            _sections.add(uiSection);
          }
          
          // Update status
          _isPublished = form.isPublished;
          _formStatus = form.status;
          
          _isLoading = false;
          notifyListeners();
          
        case Error<FormModel?>(:final error):
          _errorMessage = 'Failed to load form: ${error.toString()}';
          _isLoading = false;
          // Still create a default section so the UI isn't empty
          addSection();
          notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Error loading form: $e';
      _isLoading = false;
      // Still create a default section so the UI isn't empty
      addSection();
      notifyListeners();
    }
  }
  
  /// Helper method to convert a QuestionModel to UI format
  Map<String, dynamic> _convertQuestionToUI(QuestionModel question) {
    final uiQuestion = <String, dynamic>{
      'id': question.id,
      'type': _questionTypeToString(question.type),
      'question': question.questionText,
      'required': question.isRequired,
    };
    
    // Handle type-specific data
    switch (question.type) {
      case QuestionType.multipleChoice:
        if (question.options != null) {
          uiQuestion['options'] = List<String>.from(question.options!);
        }
        break;
      case QuestionType.checkbox:
        if (question.options != null) {
          uiQuestion['options'] = List<String>.from(question.options!);
        }
        if (question.config != null && question.config!['maxSelections'] != null) {
          uiQuestion['config'] = {
            'maxSelections': question.config!['maxSelections'],
          };
        }
        break;
      case QuestionType.ratingScale:
        if (question.config != null) {
          uiQuestion['config'] = {
            'min': question.config!['min'] ?? 1,
            'max': question.config!['max'] ?? 5,
          };
        }
        break;
      case QuestionType.date:
        if (question.config != null) {
          uiQuestion['config'] = {
            'includeTime': question.config!['includeTime'] ?? false,
            'minDate': question.config!['minDate'],
            'maxDate': question.config!['maxDate'],
          };
        }
        break;
      case QuestionType.fileUpload:
        if (question.config != null) {
          uiQuestion['config'] = {
            'allowedFileTypes': question.config!['allowedFileTypes'] ?? [],
            'maxFileSizeMB': question.config!['maxFileSizeMB'] ?? 10,
          };
        }
        break;
      default:
        break;
    }
    
    return uiQuestion;
  }
  
  /// Convert QuestionType enum to UI string
  String _questionTypeToString(QuestionType type) {
    switch (type) {
      case QuestionType.text:
        return 'Text';
      case QuestionType.multipleChoice:
        return 'Multiple Choice';
      case QuestionType.checkbox:
        return 'Checkbox';
      case QuestionType.ratingScale:
        return 'Rating Scale';
      case QuestionType.date:
        return 'Date';
      case QuestionType.fileUpload:
        return 'File Upload';
    }
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
      // Don't notify listeners on every keystroke - let TextField handle it
    }
  }
  
  void updateSectionDescription(int sectionIndex, String description) {
    if (sectionIndex >= 0 && sectionIndex < _sections.length) {
      _sections[sectionIndex]['description'] = description;
      // Don't notify listeners on every keystroke - let TextField handle it
    }
  }
  
  void addQuestion(int sectionIndex, String questionType) {
    if (sectionIndex >= 0 && sectionIndex < _sections.length) {
      final questions = _sections[sectionIndex]['questions'] as List<Map<String, dynamic>>;
      
      // Build question data with type-specific configuration
      final questionData = <String, dynamic>{
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'type': questionType,
        'question': '',
        'required': false,
      };
      
      // Add options for Multiple Choice and Checkbox
      if (questionType == 'Multiple Choice') {
        questionData['options'] = ['Option 1', 'Option 2'];
      }
      
      // Add options and config for Checkbox
      if (questionType == 'Checkbox') {
        questionData['options'] = ['Option 1', 'Option 2'];
        questionData['config'] = {
          'maxSelections': null, // null = no limit
        };
      }
      
      // Add config for Rating Scale
      if (questionType == 'Rating Scale') {
        questionData['config'] = {
          'min': 1,
          'max': 5,
        };
      }
      
      // Add config for Date
      if (questionType == 'Date') {
        questionData['config'] = {
          'includeTime': false,
          'minDate': null,
          'maxDate': null,
        };
      }
      
      // Add config for File Upload
      if (questionType == 'File Upload') {
        questionData['config'] = {
          'allowedTypes': ['all'], // 'all', 'image', 'document', 'pdf'
          'maxSizeMB': 10,
          'allowMultiple': false,
        };
      }
      
      questions.add(questionData);
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
        // Don't notify listeners on every keystroke - let TextField handle it
      }
    }
  }
  
  void updateQuestionType(int sectionIndex, int questionIndex, String type) {
    if (sectionIndex >= 0 && sectionIndex < _sections.length) {
      final questions = _sections[sectionIndex]['questions'] as List<Map<String, dynamic>>;
      if (questionIndex >= 0 && questionIndex < questions.length) {
        questions[questionIndex]['type'] = type;
        
        // Add/remove options based on type
        if (type == 'Multiple Choice') {
          questions[questionIndex]['options'] = ['Option 1', 'Option 2'];
          questions[questionIndex]['config'] = null;
        } else if (type == 'Checkbox') {
          questions[questionIndex]['options'] = ['Option 1', 'Option 2'];
          questions[questionIndex]['config'] = {
            'maxSelections': null,
          };
        } else if (type == 'Rating Scale') {
          questions[questionIndex]['options'] = null;
          questions[questionIndex]['config'] = {
            'min': 1,
            'max': 5,
          };
        } else if (type == 'Date') {
          questions[questionIndex]['options'] = null;
          questions[questionIndex]['config'] = {
            'includeTime': false,
            'minDate': null,
            'maxDate': null,
          };
        } else if (type == 'File Upload') {
          questions[questionIndex]['options'] = null;
          questions[questionIndex]['config'] = {
            'allowedTypes': ['all'],
            'maxSizeMB': 10,
            'allowMultiple': false,
          };
        } else {
          questions[questionIndex]['options'] = null;
          questions[questionIndex]['config'] = null;
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
  // QUESTION OPTIONS MANAGEMENT
  // ============================================
  
  /// Updates a specific option in a Multiple Choice or Checkbox question
  void updateQuestionOption(int sectionIndex, int questionIndex, int optionIndex, String value) {
    if (sectionIndex >= 0 && sectionIndex < _sections.length) {
      final questions = _sections[sectionIndex]['questions'] as List<Map<String, dynamic>>;
      if (questionIndex >= 0 && questionIndex < questions.length) {
        final options = questions[questionIndex]['options'] as List<String>?;
        if (options != null && optionIndex >= 0 && optionIndex < options.length) {
          options[optionIndex] = value;
          // Don't notify listeners on every keystroke - let TextField handle it
        }
      }
    }
  }
  
  /// Adds a new option to a Multiple Choice or Checkbox question
  void addQuestionOption(int sectionIndex, int questionIndex) {
    if (sectionIndex >= 0 && sectionIndex < _sections.length) {
      final questions = _sections[sectionIndex]['questions'] as List<Map<String, dynamic>>;
      if (questionIndex >= 0 && questionIndex < questions.length) {
        final options = questions[questionIndex]['options'] as List<String>?;
        if (options != null) {
          options.add('Option ${options.length + 1}');
          notifyListeners();
        }
      }
    }
  }
  
  /// Removes an option from a Multiple Choice or Checkbox question
  void removeQuestionOption(int sectionIndex, int questionIndex, int optionIndex) {
    if (sectionIndex >= 0 && sectionIndex < _sections.length) {
      final questions = _sections[sectionIndex]['questions'] as List<Map<String, dynamic>>;
      if (questionIndex >= 0 && questionIndex < questions.length) {
        final options = questions[questionIndex]['options'] as List<String>?;
        if (options != null && optionIndex >= 0 && optionIndex < options.length && options.length > 2) {
          options.removeAt(optionIndex);
          notifyListeners();
        }
      }
    }
  }
  
  /// Updates rating scale configuration (min and max values)
  void updateRatingScaleConfig(int sectionIndex, int questionIndex, {required int min, required int max}) {
    if (sectionIndex >= 0 && sectionIndex < _sections.length) {
      final questions = _sections[sectionIndex]['questions'] as List<Map<String, dynamic>>;
      if (questionIndex >= 0 && questionIndex < questions.length) {
        questions[questionIndex]['config'] = {
          'min': min,
          'max': max,
        };
        notifyListeners();
      }
    }
  }
  
  /// Updates checkbox maximum selections configuration
  void updateCheckboxMaxSelections(int sectionIndex, int questionIndex, {int? maxSelections}) {
    if (sectionIndex >= 0 && sectionIndex < _sections.length) {
      final questions = _sections[sectionIndex]['questions'] as List<Map<String, dynamic>>;
      if (questionIndex >= 0 && questionIndex < questions.length) {
        final currentConfig = questions[questionIndex]['config'] as Map<String, dynamic>? ?? {};
        questions[questionIndex]['config'] = {
          ...currentConfig,
          'maxSelections': maxSelections,
        };
        notifyListeners();
      }
    }
  }
  
  /// Updates date question configuration
  void updateDateConfig(int sectionIndex, int questionIndex, {bool? includeTime, DateTime? minDate, DateTime? maxDate}) {
    if (sectionIndex >= 0 && sectionIndex < _sections.length) {
      final questions = _sections[sectionIndex]['questions'] as List<Map<String, dynamic>>;
      if (questionIndex >= 0 && questionIndex < questions.length) {
        final currentConfig = questions[questionIndex]['config'] as Map<String, dynamic>? ?? {};
        questions[questionIndex]['config'] = {
          'includeTime': includeTime ?? currentConfig['includeTime'] ?? false,
          'minDate': minDate?.toIso8601String() ?? currentConfig['minDate'],
          'maxDate': maxDate?.toIso8601String() ?? currentConfig['maxDate'],
        };
        notifyListeners();
      }
    }
  }
  
  /// Updates file upload question configuration
  void updateFileUploadConfig(int sectionIndex, int questionIndex, {List<String>? allowedTypes, int? maxSizeMB, bool? allowMultiple}) {
    if (sectionIndex >= 0 && sectionIndex < _sections.length) {
      final questions = _sections[sectionIndex]['questions'] as List<Map<String, dynamic>>;
      if (questionIndex >= 0 && questionIndex < questions.length) {
        final currentConfig = questions[questionIndex]['config'] as Map<String, dynamic>? ?? {};
        questions[questionIndex]['config'] = {
          'allowedTypes': allowedTypes ?? currentConfig['allowedTypes'] ?? ['all'],
          'maxSizeMB': maxSizeMB ?? currentConfig['maxSizeMB'] ?? 10,
          'allowMultiple': allowMultiple ?? currentConfig['allowMultiple'] ?? false,
        };
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
  // PUBLISH FORM - Function 2
  // ============================================
  
  /// Validates and publishes the form.
  /// 
  /// Pre-publish validation:
  /// - Title must not be empty
  /// - At least one section with questions
  /// - Form must be saved first
  Future<Result<FormModel>> publishForm() async {
    // Step 1: Validation
    if (!_validateFormForPublish()) {
      return Result.error(
        CustomMessageException(_validationError ?? 'Form validation failed')
      );
    }
    
    _isPublishing = true;
    _validationError = null;
    notifyListeners();
    
    try {
      // Step 2: Save form first to ensure latest edits are persisted
      if (_currentForm == null || _currentForm!.id.isEmpty) {
        final saveResult = await saveForm();
        if (saveResult is Error) {
          _isPublishing = false;
          notifyListeners();
          return saveResult;
        }
      } else {
        // Even if form exists, save latest changes
        final saveResult = await saveForm();
        if (saveResult is Error) {
          _isPublishing = false;
          notifyListeners();
          return saveResult;
        }
      }
      
      // Step 3: Publish via repository
      final result = await _formRepository.publishForm(_currentForm!.id);
      
      switch (result) {
        case Ok<FormModel>(:final value):
          _currentForm = value;
          _formStatus = FormStatus.published;
          _isPublished = true;
          _isPublishing = false;
          notifyListeners();
          return Result.ok(value);
          
        case Error<FormModel>(:final error):
          _validationError = error.toString();
          _isPublishing = false;
          notifyListeners();
          return Result.error(error);
      }
    } catch (e) {
      _validationError = 'Unexpected error: ${e.toString()}';
      _isPublishing = false;
      notifyListeners();
      return Result.error(
        CustomMessageException(_validationError!)
      );
    }
  }
  
  /// Unpublishes the form (sets back to draft).
  Future<Result<FormModel>> unpublishForm() async {
    // Validation: Form must exist and be saved
    if (_currentForm == null || _currentForm!.id.isEmpty) {
      return Result.error(
        CustomMessageException('Form must be saved before unpublishing')
      );
    }
    
    _isPublishing = true;
    _validationError = null;
    notifyListeners();
    
    try {
      final result = await _formRepository.unpublishForm(_currentForm!.id);
      
      switch (result) {
        case Ok<FormModel>(:final value):
          _currentForm = value;
          _formStatus = FormStatus.draft;
          _isPublished = false;
          _isPublishing = false;
          notifyListeners();
          return Result.ok(value);
          
        case Error<FormModel>(:final error):
          _validationError = error.toString();
          _isPublishing = false;
          notifyListeners();
          return Result.error(error);
      }
    } catch (e) {
      _validationError = 'Unexpected error: ${e.toString()}';
      _isPublishing = false;
      notifyListeners();
      return Result.error(
        CustomMessageException(_validationError!)
      );
    }
  }
  
  /// Business logic: Validates if form can be published.
  bool _validateFormForPublish() {
    if (titleController.text.trim().isEmpty) {
      _validationError = 'Form title is required';
      return false;
    }
    
    if (_sections.isEmpty) {
      _validationError = 'Form must have at least one section';
      return false;
    }
    
    final hasQuestions = _sections.any((section) {
      final questions = section['questions'] as List;
      return questions.isNotEmpty;
    });
    
    if (!hasQuestions) {
      _validationError = 'Form must have at least one question';
      return false;
    }
    
    return true;
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
      createdBy: _authRepository.currentUser?.userId ?? '',
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

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}
