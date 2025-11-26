import 'package:flutter/material.dart';

class CatnaFormCreatorViewModel extends ChangeNotifier {
  // Form controllers
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  
  // Form state
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  bool _isPublished = false;
  bool get isPublished => _isPublished;
  
  // List to hold form sections with questions
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
  
  CatnaFormCreatorViewModel() {
    _initializeForm();
  }
  
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
  
  Future<void> saveForm() async {
    _isLoading = true;
    notifyListeners();
    
    // Simulate saving
    await Future.delayed(const Duration(seconds: 2));
    
    _isLoading = false;
    notifyListeners();
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
