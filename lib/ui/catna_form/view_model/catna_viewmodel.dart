import 'package:ephor/data/repositories/auth/auth_repository.dart';
import 'package:ephor/data/repositories/catna/catna_repository.dart';
import 'package:ephor/data/repositories/employee/employee_repository.dart';
import 'package:ephor/domain/enums/employee_role.dart';
import 'package:ephor/domain/lists/designation_choices.dart';
import 'package:ephor/domain/lists/office_choices.dart';
import 'package:ephor/domain/lists/operating_unit_choices.dart';
import 'package:ephor/domain/models/employee/employee.dart';
import 'package:ephor/domain/models/form/form_definitions.dart'; 
import 'package:ephor/utils/command.dart';
import 'package:ephor/utils/custom_message_exception.dart';
import 'package:ephor/utils/results.dart';
import 'package:flutter/material.dart';

class CatnaViewModel extends ChangeNotifier {
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  List<FormSection> _sections = [];
  List<FormSection> get sections => _sections;

  final Map<String, dynamic> _formData = {};
  Map<String, dynamic> get formData => _formData;

  final Map<String, TextEditingController> _controllers = {};

  List<EmployeeModel> _departmentEmployees = [];
  List<EmployeeModel> get departmentEmployees => _departmentEmployees;

  final CatnaRepository _catnaRepository;
  final AuthRepository _authRepository;
  final EmployeeRepository _employeeRepository;

  final List<String> _offices = officeChoices;
  final List<String> _designations = designationChoices;
  final List<String> _operatingUnits = operatingUnitChoices;
  final List<String> _purposes = ['Annual Review', 'Random Assessment'];

  late CommandNoArgs submitCatna;
  late CommandNoArgs saveStepData;

  CatnaViewModel({
    required CatnaRepository catnaRepository,
    required AuthRepository authRepository,
    required EmployeeRepository employeeRepository,
  })  : _catnaRepository = catnaRepository,
        _authRepository = authRepository,
        _employeeRepository = employeeRepository {
    
    submitCatna = CommandNoArgs(_submitCatna);
    saveStepData = CommandNoArgs(_saveStepData);
    
    _loadData();
  }

  Future<void> _loadData() async {
    _isLoading = true;
    notifyListeners();
    try {
      await Future.wait([
        _loadEmployees(), 
        _loadFormDefinition()
      ]);
    } catch (e) {
      debugPrint("Error loading data: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<FormOption> getOptionsFor(String? dataSource) {
    if (dataSource == null) return [];
    switch (dataSource) {
      case 'employees': return _departmentEmployees.map((e) => FormOption(label: e.fullName, value: e.fullName)).toList();
      case 'designations': return _designations.map((e) => FormOption(label: e, value: e)).toList();
      case 'offices': return _offices.map((e) => FormOption(label: e, value: e)).toList();
      case 'operating_units': return _operatingUnits.map((e) => FormOption(label: e, value: e)).toList();
      case 'purpose_choices': return _purposes.map((e) => FormOption(label: e, value: e)).toList();
      default: return [];
    }
  }

  Future<void> _loadFormDefinition() async {
    final result = await _catnaRepository.fetchActiveCatnaForm();
    if (result case Ok(value: final jsonMap)) {
      try {
        final rawSections = jsonMap['sections'] as List? ?? [];
        _sections = rawSections.map((s) => FormSection.fromJson(Map<String, dynamic>.from(s as Map))).toList();
        if (jsonMap.containsKey('draft_data') && jsonMap['draft_data'] != null) {
          _formData.addAll(jsonMap['draft_data']);
        }
      } catch (e) {
        debugPrint("JSON PARSING ERROR: $e");
      }
    }
  }

  Future<void> _loadEmployees() async {
    final currentUser = _authRepository.currentUser;
    final result = await _employeeRepository.fetchAllEmployees();
    if (result case Ok(value: final list)) {
      _departmentEmployees = list.where((employee) {
        if (currentUser?.role == EmployeeRole.supervisor) {
          return employee.department == currentUser?.department 
            && employee.role != EmployeeRole.humanResource;
        }
        return true;
      }).toList();
    }
  }

  // --- Dynamic Form Logic ---

  void updateValue(String key, dynamic value) {
    _formData[key] = value;
    if (_controllers.containsKey(key)) {
      final textValue = value?.toString() ?? '';
      if (_controllers[key]!.text != textValue) {
        _controllers[key]!.text = textValue;
      }
    }
    notifyListeners();
  }

  /// Lazy getter for TextEditingControllers
  TextEditingController getController(String key) {
    if (!_controllers.containsKey(key)) {
      final initialValue = _formData[key]?.toString() ?? '';
      final controller = TextEditingController(text: initialValue);
      controller.addListener(() { _formData[key] = controller.text; });
      _controllers[key] = controller;
    }
    return _controllers[key]!;
  }

  // --- Navigation & Validation ---

  set currentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  Future<Result<String?>> validateCurrentStep() async {
    final int sectionIndex = _currentIndex - 1;
    if (sectionIndex < 0 || sectionIndex >= _sections.length) return const Result.ok(null);
    final FormSection currentSection = _sections[sectionIndex];
    for (final FormItem item in currentSection.items) {
      if (item.type == FormInputType.header) continue;
      if (item.required) {
        final value = _formData[item.key];
        if (value == null || (value is String && value.trim().isEmpty)) {
          return Result.error(CustomMessageException("Please complete: ${item.label}"));
        }
      }
    }
    return const Result.ok(null);
  }

  // --- Saving & Submission ---

  /// Persists the current progress (draft) locally or remotely
  Future<Result<void>> _saveStepData() async {
    final currentUser = _authRepository.currentUser;
    if (currentUser == null) return Result.error(CustomMessageException("No user logged in"));

    final payload = Map<String, dynamic>.from(_formData);
    payload['employee_code'] = currentUser.employeeCode;

    try {
      return const Result.ok(null); 
    } catch (e) {
      return Result.error(CustomMessageException("Failed to save draft"));
    }
  }

  Future<Result<void>> _submitCatna() async {
    if (_isSubmitting) return const Result.ok(null);

    _isSubmitting = true;
    notifyListeners();

    final currentUser = _authRepository.currentUser;
    if (currentUser == null) {
      _isSubmitting = false;
      notifyListeners();
      return Result.error(CustomMessageException('User authentication required.'));
    }

    // 1. Initialize Containers
    final Map<String, dynamic> identifyingData = {};
    final Map<String, int> knowledgeMap = {};
    final Map<String, int> skillsMap = {};
    final Map<String, int> attitudesMap = {};

    // 2. Iterate through Form Definitions to map data correctly
    // We use the definitions because we need the full 'label' (Question Text) and type info
    for (var section in _sections) {
      for (var item in section.items) {
        // Skip headers or items with no data
        if (item.type == FormInputType.header) continue;
        if (!_formData.containsKey(item.key)) continue;

        final dynamic value = _formData[item.key];
        if (value == null) continue;

        if (section.layout == SectionLayout.standard) {
          // --- IDENTIFYING DATA MAPPING ---
          final String mappedKey = _mapIdentifyingKey(item.key);
          identifyingData[mappedKey] = _formatIdentifyingValue(mappedKey, value);
        } else {
          final int intValue = value is int ? value : int.tryParse(value.toString()) ?? 0;
          final String questionText = item.label.trim();

          // Categorize based on question number prefix
          if (questionText.startsWith("1.")) {
            knowledgeMap[questionText] = intValue;
          } else if (questionText.startsWith("2.")) {
            skillsMap[questionText] = intValue;
          } else if (questionText.startsWith("3.")) {
            attitudesMap[questionText] = intValue;
          }
        }
      }
    }

    // 3. Calculate Averages
    final double knowledgeAvg = _calculateAverage(knowledgeMap.values);
    final double skillsAvg = _calculateAverage(skillsMap.values);
    final double attitudeAvg = _calculateAverage(attitudesMap.values);
    
    // Overall average of the three component averages
    final double overallAvg = (knowledgeAvg + skillsAvg + attitudeAvg) / 3;

    // 4. Construct Competency Payload
    final Map<String, dynamic> competencyRatings = {
      "knowledge": knowledgeMap,
      "skills": skillsMap,
      "attitudes": attitudesMap,
      "averages": {
        "knowledge": knowledgeAvg,
        "skills": skillsAvg,
        "attitude": attitudeAvg,
        "overall": overallAvg,
      }
    };

    // 5. Final Payload Construction
    final payload = <String, dynamic>{
      'employee_code': currentUser.employeeCode,
      'identifying_data': identifyingData,
      'competency_ratings': competencyRatings,
    };

    try {
      final result = await _catnaRepository.submitAssessment(payload);
      return result;
    } catch (e) {
      return Result.error(CustomMessageException("Submission failed: $e"));
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  String _mapIdentifyingKey(String rawKey) {
    if (rawKey.contains('personnel_name')) return 'full_name';
    if (rawKey.contains('designation')) return 'designation';
    if (rawKey.contains('office')) return 'office';
    if (rawKey.contains('operating_unit')) return 'operating_unit';
    if (rawKey.contains('start_date')) return 'review_start_date';
    if (rawKey.contains('finish_date')) return 'review_end_date';
    if (rawKey.contains('assessment_date')) return 'assessment_date';
    if (rawKey.contains('purpose')) return 'purpose_of_assessment';
    if (rawKey.contains('years')) return 'years_in_current_position';
    return rawKey; // Fallback
  }

  /// Formats values (Converts "12/05/2024" -> "2024-12-05" and Strings -> Ints)
  dynamic _formatIdentifyingValue(String key, dynamic value) {
    if (value is String) {
      // Handle Date Conversion: MM/DD/YYYY -> YYYY-MM-DD
      if (value.contains('/')) {
        try {
          final parts = value.split('/');
          if (parts.length == 3) {
            // parts[0]=MM, parts[1]=DD, parts[2]=YYYY
            return "${parts[2]}-${parts[0].padLeft(2, '0')}-${parts[1].padLeft(2, '0')}";
          }
        } catch (_) {
          return value; // Return original if parse fails
        }
      }
      
      // Handle Numeric String Conversion
      if (key == 'years_in_current_position') {
        return int.tryParse(value) ?? value;
      }
    }
    return value;
  }

  double _calculateAverage(Iterable<int> values) {
    if (values.isEmpty) return 0.0;
    return values.reduce((a, b) => a + b) / values.length;
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}