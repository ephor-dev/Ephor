// ui/add_employee/view_model/add_employee_viewmodel.dart

import 'package:ephor/data/repositories/employee/abstract_employee_repository.dart';
import 'package:ephor/utils/custom_message_exception.dart';
import 'package:flutter/material.dart';

import 'package:ephor/domain/models/employee/employee.dart';
import 'package:ephor/utils/command.dart';
import 'package:ephor/utils/results.dart'; // Used in the underlying command's implementation

/// Parameter type for the Command: Contains all necessary data for submission.
typedef AddEmployeeParams = ({
  String lastName,
  String firstName,
  String middleName,
  EmployeeType employeeType,
  String? department,
  String tags,
  String? photoUrl,
});

class AddEmployeeViewModel extends ChangeNotifier {
  
  final AbstractEmployeeRepository repository; 

  AddEmployeeViewModel({required this.repository});

  // --- UI State (Text Controllers) ---
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController middleNameController = TextEditingController();
  final TextEditingController tagsController = TextEditingController();
  
  // --- UI State (Selections) ---
  EmployeeType employeeType = EmployeeType.personnel;
  String? selectedDepartment = 'EE Department';
  bool noDepartment = false;
  String? photoUrl;

  final List<String> departments = <String>[
    'EE Department', 'CE Department', 'ChE Department', 'ECE Department',
    'IE Department', 'ME Department', 'IT Department',
  ];

  // --- Reactive Command ---
  late final CommandWithArgs addEmployee;

  // --- Initializer and Command Setup ---
  void initialize() {
    addEmployee = CommandWithArgs<void, AddEmployeeParams>(_addEmployee);
  }
  
  // --- Disposable Resources ---
  @override
  void dispose() {
    lastNameController.dispose();
    firstNameController.dispose();
    middleNameController.dispose();
    tagsController.dispose();
    super.dispose();
  }
  
  // --- Mutator Callbacks for UI interaction ---
  
  void setEmployeeType(EmployeeType type) {
    employeeType = type;
  }

  void setNoDepartment(bool value) {
    noDepartment = value;
    if (noDepartment) selectedDepartment = null;
  }

  void setDepartment(String? value) {
    selectedDepartment = value;
  }
  
  // --- Core Command Implementation ---

  Future<Result<EmployeeModel>> _addEmployee(AddEmployeeParams params) async {
    // 1. Validation 
    final String? validationError = _validateForm(params);
    if (validationError != null) {
      return Result.error(CustomMessageException(validationError));
    }

    // 2. Create Model and Save (Delegation to Repository)
    try {
      final EmployeeModel employee = _createEmployeeModel(params);
      
      final result = await repository.addEmployee(employee);

      switch (result) {
        case Ok():
          return Result.ok(employee);
        case Error():
          return Result.error(CustomMessageException("Failed adding employee"));
      }
    } catch (e) {
      return Result.error(CustomMessageException('An unexpected error occurred during submission: ${e.toString()}'));
    }
  }

  // --- Helper Methods ---

  String? _validateForm(AddEmployeeParams params) {
    if (params.lastName.isEmpty) return 'Last Name is required';
    if (params.firstName.isEmpty) return 'First Name is required';
    if (params.lastName.length < 2) return 'Last Name must be at least 2 characters';
    if (params.firstName.length < 2) return 'First Name must be at least 2 characters';
    return null;
  }

  EmployeeModel _createEmployeeModel(AddEmployeeParams params) {
    final List<String> tagList = params.tags
        .split(',')
        .map((String e) => e.trim())
        .where((String e) => e.isNotEmpty)
        .toList(growable: false);

    return EmployeeModel(
      id: UniqueKey().toString(),
      lastName: params.lastName,
      firstName: params.firstName,
      middleName: params.middleName.isEmpty ? null : params.middleName,
      employeeType: params.employeeType,
      department: params.department,
      extraTags: tagList,
      photoUrl: params.photoUrl,
      createdAt: DateTime.now(),
    );
  }
}