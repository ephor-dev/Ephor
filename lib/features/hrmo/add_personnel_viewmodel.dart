import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'personnel_model.dart';

/// Result class for form submission
class FormSubmissionResult {
  final bool success;
  final String? errorMessage;
  final PersonnelModel? personnel;

  const FormSubmissionResult({
    required this.success,
    this.errorMessage,
    this.personnel,
  });
}

class AddPersonnelViewModel extends ChangeNotifier {
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController middleNameController = TextEditingController();
  final TextEditingController tagsController = TextEditingController();

  final List<String> departments = <String>[
    'EE Department',
    'CE Department',
    'ChE Department',
    'ECE Department',
    'IE Department',
    'ME Department',
    'IT Department',
  ];

  EmployeeType employeeType = EmployeeType.personnel;
  String? selectedDepartment = 'EE Department';
  bool noDepartment = false;
  String? photoUrl;

  // Loading and error states
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ThemeMode themeMode = ThemeMode.light;

  void toggleThemeMode() {
    themeMode = themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setEmployeeType(EmployeeType type) {
    employeeType = type;
    notifyListeners();
  }

  void setNoDepartment(bool value) {
    noDepartment = value;
    if (noDepartment) selectedDepartment = null;
    notifyListeners();
  }

  void setDepartment(String? value) {
    selectedDepartment = value;
    notifyListeners();
  }

  void setPhotoUrl(String? url) {
    photoUrl = url;
    notifyListeners();
  }

  /// Validates the form and returns error message if invalid, null if valid
  String? _validateForm() {
    final String lastName = lastNameController.text.trim();
    final String firstName = firstNameController.text.trim();

    if (lastName.isEmpty) {
      return 'Last Name is required';
    }
    if (firstName.isEmpty) {
      return 'First Name is required';
    }

    // Additional validation can be added here
    if (lastName.length < 2) {
      return 'Last Name must be at least 2 characters';
    }
    if (firstName.length < 2) {
      return 'First Name must be at least 2 characters';
    }

    return null; // Form is valid
  }

  /// Creates a PersonnelModel from current form values
  PersonnelModel _createPersonnelModel() {
    final String lastName = lastNameController.text.trim();
    final String firstName = firstNameController.text.trim();
    final String? middleName = middleNameController.text.trim().isEmpty
        ? null
        : middleNameController.text.trim();

    final List<String> tagList = tagsController.text
        .split(',')
        .map((String e) => e.trim())
        .where((String e) => e.isNotEmpty)
        .toList(growable: false);

    return PersonnelModel(
      id: UniqueKey().toString(),
      lastName: lastName,
      firstName: firstName,
      middleName: middleName,
      employeeType: employeeType,
      department: noDepartment ? null : selectedDepartment,
      extraTags: tagList,
      photoUrl: photoUrl,
      createdAt: DateTime.now(),
    );
  }

  /// Stubbed database save function
  /// This will be replaced with actual Supabase/Firebase call later
  Future<void> _savePersonnelData(PersonnelModel data) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Print to console for debugging
    debugPrint('=== Personnel Data to Save ===');
    debugPrint('ID: ${data.id}');
    debugPrint('Full Name: ${data.fullName}');
    debugPrint('Employee Type: ${data.employeeType.name}');
    debugPrint('Department: ${data.department ?? 'None'}');
    debugPrint('Extra Tags: ${data.extraTags.join(', ')}');
    debugPrint('Photo URL: ${data.photoUrl ?? 'None'}');
    debugPrint('Created At: ${data.createdAt}');
    debugPrint('JSON: ${data.toJson()}');
    debugPrint('============================');

    // In the future, this will be:
    // await supabase.from('personnel').insert(data.toJson());
    // or
    // await firebaseFirestore.collection('personnel').add(data.toJson());
  }

  /// Main submit method - validates form, creates model, and saves
  /// Returns FormSubmissionResult with success status and error message if any
  Future<FormSubmissionResult> submitForm() async {
    // Clear previous error
    _errorMessage = null;
    notifyListeners();

    // Validate form
    final String? validationError = _validateForm();
    if (validationError != null) {
      _errorMessage = validationError;
      notifyListeners();
      return FormSubmissionResult(
        success: false,
        errorMessage: validationError,
      );
    }

    // Create personnel model
    final PersonnelModel personnel = _createPersonnelModel();

    // Set loading state
    _isLoading = true;
    notifyListeners();

    try {
      // Save to database (stubbed)
      await _savePersonnelData(personnel);

      // Success
      _isLoading = false;
      notifyListeners();

      return FormSubmissionResult(
        success: true,
        personnel: personnel,
      );
    } catch (e) {
      // Handle error
      _isLoading = false;
      _errorMessage = 'Failed to save personnel data: ${e.toString()}';
      notifyListeners();

      return FormSubmissionResult(
        success: false,
        errorMessage: _errorMessage,
      );
    }
  }

  /// Legacy method for backward compatibility
  /// Use submitForm() instead
  @Deprecated('Use submitForm() instead')
  PersonnelModel? confirm() {
    final String? validationError = _validateForm();
    if (validationError != null) {
      return null;
    }
    return _createPersonnelModel();
  }

  @override
  void dispose() {
    lastNameController.dispose();
    firstNameController.dispose();
    middleNameController.dispose();
    tagsController.dispose();
    super.dispose();
  }
}


