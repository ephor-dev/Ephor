import 'package:ephor/data/repositories/catna/abstract_catna_repository.dart';
import 'package:ephor/data/repositories/catna/catna_repository.dart';
import 'package:flutter/material.dart';

class CatnaForm1ViewModel extends ChangeNotifier {
  Map<String, dynamic>? _identifyingData;
  Map<String, dynamic>? get identifyingData => _identifyingData;

  // Text Controllers
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController middleNameController = TextEditingController();
  final TextEditingController yearsInCurrentPositionController = TextEditingController();
  final TextEditingController dateStartedController = TextEditingController();
  final TextEditingController dateFinishedController = TextEditingController();
  final TextEditingController assessmentDateController = TextEditingController();

  // Dropdown selections
  String? _selectedDesignation;
  String? _selectedOffice;
  String? _selectedOperatingUnit;
  String? _selectedPurpose;

  // Date fields
  DateTime? _dateStarted;
  DateTime? _dateFinished;
  DateTime? _assessmentDate;

  final AbstractCATNARepository _catnaRepository;

  CatnaForm1ViewModel({required CatnaRepository catnaRepository})
    : _catnaRepository = catnaRepository {
    _restoreFromShared();
  }

  void saveIdentifyingData(Map<String, dynamic> data) {
    _catnaRepository.keepInMemoryIdentifyingData(Map<String, dynamic>.from(data));
    notifyListeners();
  }

  // Getters
  String? get selectedDesignation => _selectedDesignation;
  String? get selectedOffice => _selectedOffice;
  String? get selectedOperatingUnit => _selectedOperatingUnit;
  String? get selectedPurpose => _selectedPurpose;
  DateTime? get dateStarted => _dateStarted;
  DateTime? get dateFinished => _dateFinished;
  DateTime? get assessmentDate => _assessmentDate;

  // Setters
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

  /// Restores form state from the shared view model if data exists.
  void _restoreFromShared() {
    final saved = identifyingData;
    if (saved == null) return;

    firstNameController.text = saved['first_name'] as String? ?? '';
    lastNameController.text = saved['last_name'] as String? ?? '';
    middleNameController.text = saved['middle_name'] as String? ?? '';
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
      } catch (e) {
        // Invalid date, ignore
      }
    }

    final endDateStr = saved['review_end_date'] as String?;
    if (endDateStr != null) {
      try {
        _dateFinished = DateTime.parse(endDateStr);
        dateFinishedController.text =
            '${_dateFinished!.month.toString().padLeft(2, '0')}/${_dateFinished!.day.toString().padLeft(2, '0')}/${_dateFinished!.year}';
      } catch (e) {
        // Invalid date, ignore
      }
    }

    final assessmentDateStr = saved['assessment_date'] as String?;
    if (assessmentDateStr != null) {
      try {
        _assessmentDate = DateTime.parse(assessmentDateStr);
        assessmentDateController.text =
            '${_assessmentDate!.month.toString().padLeft(2, '0')}/${_assessmentDate!.day.toString().padLeft(2, '0')}/${_assessmentDate!.year}';
      } catch (e) {
        // Invalid date, ignore
      }
    }

    notifyListeners();
  }

  /// Validates that all required fields are filled.
  String? validateForm() {
    if (firstNameController.text.trim().isEmpty ||
        lastNameController.text.trim().isEmpty ||
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
    return null; // All validations passed
  }

  /// Builds the identifying data JSON map for saving to shared view model.
  Map<String, dynamic> buildIdentifyingData() {
    return {
      'first_name': firstNameController.text.trim(),
      'last_name': lastNameController.text.trim(),
      'middle_name': middleNameController.text.trim(),
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

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    middleNameController.dispose();
    yearsInCurrentPositionController.dispose();
    dateStartedController.dispose();
    dateFinishedController.dispose();
    assessmentDateController.dispose();
    super.dispose();
  }

  
}