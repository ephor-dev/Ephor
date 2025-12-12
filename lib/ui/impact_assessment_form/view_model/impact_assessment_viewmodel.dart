import 'package:ephor/data/repositories/auth/auth_repository.dart';
import 'package:ephor/data/repositories/form/form_repository.dart';
import 'package:ephor/data/repositories/employee/employee_repository.dart';
import 'package:ephor/domain/enums/employee_role.dart';
import 'package:ephor/domain/lists/office_choices.dart';
import 'package:ephor/domain/models/employee/employee.dart';
import 'package:ephor/domain/models/form/form_definitions.dart';
import 'package:ephor/utils/command.dart';
import 'package:ephor/utils/custom_message_exception.dart';
import 'package:ephor/utils/results.dart';
import 'package:flutter/material.dart';

class ImpactAssessmentViewModel extends ChangeNotifier {
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

  // --- Dependencies ---
  final FormRepository _formRepository; // Assuming generic form methods reside here
  final AuthRepository _authRepository;
  final EmployeeRepository _employeeRepository;

  // --- Lists ---
  final List<String> _offices = officeChoices;
  final List<String> _interventionTypes = [
    'Training',
    'Workshop',
    'Seminar/Webinar',
    'Conference',
    'Orientation'
  ];

  // --- Commands ---
  late CommandNoArgs submitAssessment;
  late CommandNoArgs saveStepData;

  ImpactAssessmentViewModel({
    required FormRepository formRepository,
    required AuthRepository authRepository,
    required EmployeeRepository employeeRepository,
  })  : _formRepository = formRepository,
        _authRepository = authRepository,
        _employeeRepository = employeeRepository {
    
    submitAssessment = CommandNoArgs(_submitImpactAssessment);
    saveStepData = CommandNoArgs(_saveStepData);
    _loadData();
  }

  // --- Data Loading ---

  Future<void> _loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.wait([
        _loadFormDefinition(),
        _loadEmployees(),
      ]);
    } catch (e) {
      debugPrint("Critical Error loading Impact Assessment data: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadFormDefinition() async {
    final result = await _formRepository.fetchActiveImpactAssessmentForm();

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
          return employee.department == currentUser?.department &&
            employee.role != EmployeeRole.humanResource
            && employee.catnaAssessed && !employee.impactAssessed;
        }
        return true;
      }).toList();
    }
  }

  // --- Dynamic Helpers ---

  List<FormOption> getOptionsFor(String? dataSource) {
    if (dataSource == null) return [];
    switch (dataSource) {
      case 'employees':
        return _departmentEmployees.map((e) => FormOption(label: e.fullName, value: e.fullName)).toList();
      case 'offices':
        return _offices.map((e) => FormOption(label: e, value: e)).toList();
      case 'intervention_types':
        return _interventionTypes.map((e) => FormOption(label: e, value: e)).toList();
      default:
        return [];
    }
  }

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

  TextEditingController getController(String key) {
    if (!_controllers.containsKey(key)) {
      final initialValue = _formData[key]?.toString() ?? '';
      final controller = TextEditingController(text: initialValue);
      controller.addListener(() {
        _formData[key] = controller.text;
      });
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
    if (sectionIndex < 0 || sectionIndex >= _sections.length) {
      return const Result.ok(null);
    }

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

  // --- Submission ---

  Future<Result<void>> _saveStepData() async {
    // Implement draft saving logic here
    return const Result.ok(null);
  }

  Future<Result<void>> _submitImpactAssessment() async {
    if (_isSubmitting) return const Result.ok(null);

    _isSubmitting = true;
    notifyListeners();

    final currentUser = _authRepository.currentUser;
    if (currentUser == null) {
      _isSubmitting = false;
      notifyListeners();
      return Result.error(CustomMessageException('User authentication required.'));
    }

    final Map<String, dynamic> identifyingData = {};
    final Map<String, dynamic> assessmentData = {};

    // We iterate through the sections to know which keys belong where
    for (var section in _sections) {
      for (var item in section.items) {
        if (!_formData.containsKey(item.key)) continue;
        
        final value = _formData[item.key];

        if (section.title.contains("Identifying")) {
          identifyingData[item.key] = value;
        } else {
          // Everything else (Section II) goes to assessment
          assessmentData[item.label] = value;
        }
      }
    }

    String employeeCode = "";

    try {
      final listResult = await _employeeRepository.fetchAllEmployees();

      if (listResult case Ok(value: List<EmployeeModel> employeeList)) {
        for (EmployeeModel employee in employeeList) {
          if (employee.fullName == identifyingData['personnel_name']) {
            employeeCode = employee.employeeCode;
            break;
          }
        }
      }

      if (employeeCode == "") {
        _isSubmitting = false;
        return Result.error(CustomMessageException("Can't retrieve user code"));
      }
    } catch (e) {
      _isSubmitting = false;
      return Result.error(CustomMessageException("Can't retrieve user code"));
    }

    final payload = <String, dynamic>{
      'employee_code': currentUser.employeeCode,
      'identifying_data': identifyingData,
      'assessments_data': assessmentData,
      'updated_user': employeeCode
    };

    try {
      final result = await _formRepository.submitImpactAssessment(payload);
      return result;
    } catch (e) {
      return Result.error(CustomMessageException("Submission failed: $e"));
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}