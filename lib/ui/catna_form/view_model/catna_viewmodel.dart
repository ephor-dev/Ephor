import 'package:ephor/data/repositories/employee/employee_repository.dart';
import 'package:ephor/domain/enums/employee_role.dart';
import 'package:ephor/domain/models/employee/employee.dart';
import 'package:ephor/utils/command.dart';
import 'package:ephor/utils/custom_message_exception.dart';
import 'package:ephor/utils/results.dart';
import 'package:flutter/material.dart';
import 'package:ephor/data/repositories/auth/auth_repository.dart';
import 'package:ephor/data/repositories/catna/catna_repository.dart';

class CatnaViewModel extends ChangeNotifier {
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;
  
  final int totalSteps = 3;

  Map<String, dynamic>? _identifyingData;
  Map<String, dynamic>? get identifyingData => _identifyingData;

  Map<String, dynamic>? _competencyRatings;
  Map<String, dynamic>? get competencyRatings => _competencyRatings;

  // --- FORM 1: Identifying Data Controllers ---
  final TextEditingController yearsInCurrentPositionController = TextEditingController();
  final TextEditingController dateStartedController = TextEditingController();
  final TextEditingController dateFinishedController = TextEditingController();
  final TextEditingController assessmentDateController = TextEditingController();

  // Dropdown selections
  String? _selectedEmployeeName;
  String? _selectedDesignation;
  String? _selectedOffice;
  String? _selectedOperatingUnit;
  String? _selectedPurpose;

  // Date fields
  DateTime? _dateStarted;
  DateTime? _dateFinished;
  DateTime? _assessmentDate;

  // --- FORM 2: Competency Data ---
  // Assessment response map: item text -> rating (1-4)
  final Map<String, int?> assessmentResponse = {};

  final List<String> knowledgeItems = [
    '1.1. (CK) Manifests foundation knowledge in the performance of assigned tasks in the academic area or work area.',
    '1.2. (CK) Has basic knowledge required to successfully and accurately accomplish duties and tasks.',
    '1.3. (CK) Possesses taught and learned facts and principles from academic area or work area.',
    '1.4. (FK) Manifests knowledge on quality, safety and professional regulatory standards.',
    '1.5. (FK) Has know-how in following University policies, rules and standards.',
    '1.6. (FK) Possesses understanding of how to describe and implement the rules or step to follow instructions at work.',
    '1.7. (SK) Shows knowledge competence in the field of work OR academic specialization in theory/constructs.',
    '1.8. (SK) Has knowledge and understanding on concepts for a particular work purpose OR academic discipline resulted from training or from self-initiated development',
    '1.9. (SK) Possesses specialized knowledge in contributing concepts/frameworks/methodology for work OR academic purposes.',
  ];

  final List<String> skillsItems = [
    '2.1. (OS) Uses resources appropriately and conscientiously to avoid wastage.',
    '2.2. (OS) Maintains privacy and confidentiality as required.',
    '2.3. (OS) Shows ability in integrating own work strategies and activities with the University vision, mission and goals.',
    '2.4. (FS) When conflict arises, goes to the source of conflict to achieve the best possible resolution.',
    '2.5. (FS) Communicates the right information, in the right manner, to the right people (co-workers, customers & other stakeholders) at the right time.',
    '2.6. (FS) Exhibits skills required to successfully and accurately accomplish duties and tasks in a timely manner.',
    '2.7. (SMS) Works efficiently under pressure and is able to balance multiple priorities.',
    '2.8. (SMS) Shows the initiative to develop skills and enhance knowledge for better work performance.',
    '2.9. (SMS) Practices active listening skills and follows instructions accurately.',
  ];

  final List<String> attitudeItems = [
    '3.1. (AW) Meets expectations related to attendance, punctuality, breaks and attendance to the flag raisingceremony.',
    '3.2. (AW) Demonstrates appreciation of the University strategic direction and its pursuit to the institutional goals and objectives.',
    '3.3. (AW) Promotes excellence and continuous improvement at work surpassing standards of expectations.',
    '3.4. (ACW) Shares pertinent information and knowledge to assist co-workers.',
    '3.5. (ACW) Exhibits dependability in co-worker or team while observing business decorum and aprofessional approach at work.',
    '3.6. (ACW) Engages in co-worker/team in any and other collective activities organized by the department/college/University.',
    '3.7. (ACS) Shows service-oriented attitude in attending to the needs and requirement of customers and other stakeholders.',
    '3.8. (ACS) Demonstrates flexibility when dealing with customers and other stakeholders of different demographic profiles (e.g., minority, orientation, nationality, economic condition, etc.).',
    '3.9. (ACS) Represents the University in promoting its vision, mission and strategic direction in any customer and stakeholders transaction or engagement.',
  ];

  // --- General State ---
  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  List<EmployeeModel> _departmentEmployees = [];
  List<EmployeeModel> get departmentEmployees => _departmentEmployees;

  EmployeeModel? _currentUser;
  EmployeeModel? get currentUser => _currentUser;

  final AuthRepository _authRepository;
  final CatnaRepository _catnaRepository;
  final EmployeeRepository _employeeRepository;

  late CommandNoArgs saveIdentifyingData;
  late CommandNoArgs saveCompetencyRatings;
  late CommandNoArgs submitCatna;

  CatnaViewModel({
    required CatnaRepository catnaRepository, 
    required AuthRepository authRepository,
    required EmployeeRepository employeeRepository

  }) : _catnaRepository = catnaRepository,
       _authRepository = authRepository,
       _employeeRepository = employeeRepository {
    _loadEmployees();

    saveIdentifyingData = CommandNoArgs<void>(_saveIdentifyingData);
    saveCompetencyRatings = CommandNoArgs<void>(_saveCompetencyRatings);
    submitCatna = CommandNoArgs(_submitCatna);
    
    _initializeResponseMap();
    _getSavedData();
    _getCurrentUser();
  }

  Future<Result<void>> _loadEmployees() async {
    final result = await _employeeRepository.fetchAllEmployees();

    if (result case Ok(value: final list)) {
      List<EmployeeModel> departmentEmployeeList = [];

      for (EmployeeModel employee in list) {
        if (currentUser?.role == EmployeeRole.supervisor && (
          employee.role == EmployeeRole.humanResource 
          || employee.department != currentUser?.department)) {
          continue;
        }

        departmentEmployeeList.add(employee);
      }

      _departmentEmployees = departmentEmployeeList;
      notifyListeners();
      return const Result.ok(null);
    } else {
      _departmentEmployees = [];
      return result;
    }
  }

  void _getCurrentUser() {
    final currentUser = _authRepository.currentUser;
    if (currentUser == null) {
      _currentUser = null;
    } else {
      _currentUser = currentUser;
    }
    notifyListeners();
  }

  set currentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  Future<Result<void>> _saveIdentifyingData() async {
    try {
      _identifyingData = buildIdentifyingData();
      return Result.ok(null);
    } on Error {
      return Result.error(CustomMessageException("Can't save identifying data"));
    }
  }

  Future<Result<void>> _saveCompetencyRatings() async {
    try {
      _competencyRatings = buildCompetencyRatings();
      return Result.ok(null);
    } on Error {
      return Result.error(CustomMessageException("Can't save identifying data"));
    }
  }

  void _getSavedData() {
    _identifyingData = _catnaRepository.identifyingData;
    _competencyRatings = _catnaRepository.competencyRatings;
    
    // Now that data is loaded, populate the controllers and maps
    _restoreIdentifyingData();
    _restoreCompetencyData();
    
    notifyListeners();
  }

  // --- Getters for Form 1 ---
  String? get selectedDesignation => _selectedDesignation;
  String? get selectedOffice => _selectedOffice;
  String? get selectedOperatingUnit => _selectedOperatingUnit;
  String? get selectedPurpose => _selectedPurpose;
  DateTime? get dateStarted => _dateStarted;
  DateTime? get dateFinished => _dateFinished;
  DateTime? get assessmentDate => _assessmentDate;
  String? get selectedEmployeeName => _selectedEmployeeName;

  // --- Setters for Form 1 ---
  void setEmployeeName(String? value) {
    _selectedEmployeeName = value;
    notifyListeners();
  }

  void setSelectedDesignation(String? value) {
    _selectedDesignation = value;
    notifyListeners();
  }

  void setSelectedOffice(String? value) {
    _selectedOffice = value;
    notifyListeners();
  }

  void setSelectedOperatingUnit(String? value) {
    _selectedOperatingUnit = value;
    notifyListeners();
  }

  void setSelectedPurpose(String? value) {
    _selectedPurpose = value;
    notifyListeners();
  }

  void setDateStarted(DateTime? date) {
    _dateStarted = date;
    if (date != null) {
      dateStartedController.text =
          '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
    } else {
      dateStartedController.clear();
    }
    notifyListeners();
  }

  void setDateFinished(DateTime? date) {
    _dateFinished = date;
    if (date != null) {
      dateFinishedController.text =
          '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
    } else {
      dateFinishedController.clear();
    }
    notifyListeners();
  }

  void setAssessmentDate(DateTime? date) {
    _assessmentDate = date;
    if (date != null) {
      assessmentDateController.text =
          '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
    } else {
      assessmentDateController.clear();
    }
    notifyListeners();
  }

  // --- Restoration Logic ---

  /// Restores Form 1 (Identifying Data) from memory
  void _restoreIdentifyingData() {
    final saved = identifyingData;
    if (saved == null) return;

    _selectedEmployeeName = saved['full_name'] as String?;
    yearsInCurrentPositionController.text =
        (saved['years_in_current_position'] as int?)?.toString() ?? '';

    _selectedDesignation = saved['designation'] as String?;
    _selectedOffice = saved['office'] as String?;
    _selectedOperatingUnit = saved['operating_unit'] as String?;
    _selectedPurpose = saved['purpose_of_assessment'] as String?;

    // Restore dates
    final startDateStr = saved['review_start_date'] as String?;
    if (startDateStr != null) {
      try {
        _dateStarted = DateTime.parse(startDateStr);
        dateStartedController.text =
            '${_dateStarted!.month.toString().padLeft(2, '0')}/${_dateStarted!.day.toString().padLeft(2, '0')}/${_dateStarted!.year}';
      } catch (e) { /* Invalid date, ignore */ }
    }

    final endDateStr = saved['review_end_date'] as String?;
    if (endDateStr != null) {
      try {
        _dateFinished = DateTime.parse(endDateStr);
        dateFinishedController.text =
            '${_dateFinished!.month.toString().padLeft(2, '0')}/${_dateFinished!.day.toString().padLeft(2, '0')}/${_dateFinished!.year}';
      } catch (e) { /* Invalid date, ignore */ }
    }

    final assessmentDateStr = saved['assessment_date'] as String?;
    if (assessmentDateStr != null) {
      try {
        _assessmentDate = DateTime.parse(assessmentDateStr);
        assessmentDateController.text =
            '${_assessmentDate!.month.toString().padLeft(2, '0')}/${_assessmentDate!.day.toString().padLeft(2, '0')}/${_assessmentDate!.year}';
      } catch (e) { /* Invalid date, ignore */ }
    }
  }

  /// Restores Form 2 (Competency Ratings) from memory
  void _restoreCompetencyData() {
    final saved = competencyRatings;
    if (saved == null) return;

    // Helper function to restore map to assessmentResponse
    void restoreMap(Map<String, dynamic>? sourceMap) {
      if (sourceMap != null) {
        for (final entry in sourceMap.entries) {
          if (entry.value is int) {
            assessmentResponse[entry.key] = entry.value as int;
          }
        }
      }
    }

    restoreMap(saved['knowledge'] as Map<String, dynamic>?);
    restoreMap(saved['skills'] as Map<String, dynamic>?);
    restoreMap(saved['attitudes'] as Map<String, dynamic>?);
  }

  // --- Logic for Form 2 (Competency) ---

  void _initializeResponseMap() {
    final allItems = [...knowledgeItems, ...skillsItems, ...attitudeItems];
    for (var item in allItems) {
      assessmentResponse[item] = null;
    }
  }

  void setRating(String item, int? rating) {
    assessmentResponse[item] = rating;
    notifyListeners();
  }

  Map<String, int> extractRatings(List<String> items) {
    final map = <String, int>{};
    for (final item in items) {
      final value = assessmentResponse[item];
      if (value != null) {
        map[item] = value;
      }
    }
    return map;
  }

  double computeAverage(List<String> items) {
    final values = <int>[];
    for (final item in items) {
      final value = assessmentResponse[item];
      if (value != null) {
        values.add(value);
      }
    }
    if (values.isEmpty) return 0.0;
    return values.reduce((a, b) => a + b) / values.length;
  }

  // --- Validation Logic ---

  /// Main validation router that checks the current page
  Future<Result<String?>> validateCurrentStep() async {
    if (_currentIndex == 1) {
      final check1 = _validateIdentifyingData();
      if (check1 != null) {
        return Result.error(CustomMessageException(check1));
      }
      
      return Result.ok(null);
    } else if (_currentIndex == 2) {
      final check2 = _validateCompetencyData();
      if (check2 != null) {
        return Result.error(CustomMessageException(check2));
      }

      return Result.ok(null);
    }

    return Result.ok(null);
  }

  String? _validateIdentifyingData() {
    if (_selectedEmployeeName == null ||
        _selectedDesignation == null ||
        _selectedOffice == null ||
        _selectedOperatingUnit == null ||
        yearsInCurrentPositionController.text.trim().isEmpty ||
        _dateStarted == null ||
        _dateFinished == null ||
        _assessmentDate == null ||
        _selectedPurpose == null) {
      return 'All fields must be filled before proceeding to the next form';
    }
    return null;
  }

  String? _validateCompetencyData() {
    final totalKnowledgeItems = knowledgeItems.length;
    final totalSkillsItems = skillsItems.length;
    final totalAttitudeItems = attitudeItems.length;

    final knowledgeRated = knowledgeItems.where((item) => assessmentResponse[item] != null).length;
    final skillsRated = skillsItems.where((item) => assessmentResponse[item] != null).length;
    final attitudeRated = attitudeItems.where((item) => assessmentResponse[item] != null).length;

    if (knowledgeRated < totalKnowledgeItems) {
      final remaining = totalKnowledgeItems - knowledgeRated;
      return 'All knowledge competency items must be rated. $remaining item(s) remaining.';
    }

    if (skillsRated < totalSkillsItems) {
      final remaining = totalSkillsItems - skillsRated;
      return 'All skills competency items must be rated. $remaining item(s) remaining.';
    }

    if (attitudeRated < totalAttitudeItems) {
      final remaining = totalAttitudeItems - attitudeRated;
      return 'All attitude competency items must be rated. $remaining item(s) remaining.';
    }

    return null;
  }

  // --- Data Construction ---

  Map<String, dynamic> buildIdentifyingData() {
    return {
      'full_name': _selectedEmployeeName,
      'designation': _selectedDesignation,
      'office': _selectedOffice,
      'operating_unit': _selectedOperatingUnit,
      'years_in_current_position':
          int.tryParse(yearsInCurrentPositionController.text.trim()),
      'review_start_date': _dateStarted?.toIso8601String().substring(0, 10),
      'review_end_date': _dateFinished?.toIso8601String().substring(0, 10),
      'assessment_date': _assessmentDate?.toIso8601String().substring(0, 10),
      'purpose_of_assessment': _selectedPurpose,
    };
  }

  Map<String, dynamic> buildCompetencyRatings() {
    final knowledgeRatings = extractRatings(knowledgeItems);
    final skillsRatings = extractRatings(skillsItems);
    final attitudeRatings = extractRatings(attitudeItems);

    final knowledgeAvg = computeAverage(knowledgeItems);
    final skillsAvg = computeAverage(skillsItems);
    final attitudeAvg = computeAverage(attitudeItems);
    final overallAvg = (knowledgeAvg + skillsAvg + attitudeAvg) / 3;

    return {
      'knowledge': knowledgeRatings,
      'skills': skillsRatings,
      'attitudes': attitudeRatings,
      'averages': {
        'knowledge': knowledgeAvg,
        'skills': skillsAvg,
        'attitude': attitudeAvg,
        'overall': overallAvg,
      },
    };
  }

  // --- Submission ---

  bool get canSubmitAssessment {
    final currentUser = _authRepository.currentUser;
    if (currentUser == null) return false;
    return currentUser.role == EmployeeRole.humanResource ||
           currentUser.role == EmployeeRole.supervisor;
  }

  Future<Result<void>> _submitCatna() async {
    final payload = <String, dynamic>{
      if (identifyingData != null)
        'identifying_data': identifyingData,
      if (competencyRatings != null)
        'competency_ratings': competencyRatings
    };

    if (_isSubmitting) {
      return const Result.ok(null);
    }

    _isSubmitting = true;
    notifyListeners();

    // Check user authentication
    final currentUser = _authRepository.currentUser;
    if (currentUser == null) {
      _isSubmitting = false;
      notifyListeners();
      return Result.error(CustomMessageException('User authentication required. Please log in again.'));
    }

    if (!canSubmitAssessment) {
      _isSubmitting = false;
      notifyListeners();
      return Result.error(CustomMessageException(
        'You do not have permission to submit CATNA assessments. Only HR and Supervisors can submit assessments.'
      ));
    }

    try {
      // Ensure employee_code is attached
      payload['employee_code'] = currentUser.employeeCode;
      
      final result = await _catnaRepository.submitAssessment(payload);
      return result;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    yearsInCurrentPositionController.dispose();
    dateStartedController.dispose();
    dateFinishedController.dispose();
    assessmentDateController.dispose();
    super.dispose();
  }
}