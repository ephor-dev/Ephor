// ui/add_employee/view_model/add_employee_viewmodel.dart

import 'package:ephor/data/repositories/employee/abstract_employee_repository.dart';
import 'package:ephor/utils/custom_message_exception.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:ephor/domain/models/employee/employee.dart';
import 'package:ephor/utils/command.dart';
import 'package:ephor/utils/results.dart'; 

/// Parameter type for the Command: Contains all necessary data for submission.
typedef AddEmployeeParams = ({
  String lastName,
  String firstName,
  String middleName,
  EmployeeRole employeeRole, 
  String? department,
  String tags,
  String? photoUrl,
});

class AddEmployeeViewModel { 
  
  final AbstractEmployeeRepository repository; 

  AddEmployeeViewModel({required this.repository});

  // --- UI State (Text Controllers) ---
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController middleNameController = TextEditingController();
  final TextEditingController tagsController = TextEditingController();
  
  // --- UI State (Selections) ---
  EmployeeRole employeeRole = EmployeeRole.personnel; 
  String? selectedDepartment = 'EE Department';
  bool noDepartment = false;
  String? photoUrl;

  final List<String> departments = <String>[
    'EE Department', 'CE Department', 'ChE Department', 'ECE Department',
    'IE Department', 'ME Department', 'IT Department',
  ];

  // --- Reactive Command ---
  late final CommandWithArgs<void, AddEmployeeParams> addEmployee;

  // --- Initializer and Command Setup ---
  void initialize() {
    addEmployee = CommandWithArgs<void, AddEmployeeParams>(_addEmployee);
  }
  
  // --- Disposable Resources ---
  void dispose() {
    lastNameController.dispose();
    firstNameController.dispose();
    middleNameController.dispose();
    tagsController.dispose();
  }
  
  // --- Mutator Callbacks for UI interaction ---
  
  void setEmployeeRole(EmployeeRole role) {
    employeeRole = role;
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
    final String? validationError = _validateForm(params);
    if (validationError != null) {
      return Result.error(CustomMessageException(validationError));
    }

    final EmployeeModel employeeToSave = _createEmployeeModel(params);
    
    try {
      final result = await repository.addEmployee(employeeToSave);
      print(result);
      return result;
    } catch (e) {
      debugPrint('Unexpected error in VM command: $e');
      return Result.error(CustomMessageException('An unexpected error occurred during submission: ${e.toString()}'));
    }
  }

  // --- Helper Methods ---
  
  EmployeeModel _createEmployeeModel(AddEmployeeParams params) {
    final List<String> tagList = params.tags
        .split(',')
        .map((String e) => e.trim())
        .where((String e) => e.isNotEmpty)
        .toList(growable: false);

    // FIX: Pass null for the ID. The toJson() method will omit it, 
    // allowing the database to execute gen_random_uuid().
    return EmployeeModel(
      id: null, 
      employeeCode: 'AUTO_${UniqueKey().toString()}', 
      email: '${params.firstName.toLowerCase()}.${params.lastName.toLowerCase()}@example.com', 
      role: params.employeeRole,
      
      lastName: params.lastName,
      firstName: params.firstName,
      middleName: params.middleName.isEmpty ? null : params.middleName,
      department: params.department ?? 'N/A',
      extraTags: tagList,
      photoUrl: params.photoUrl,
    );
  }
  
  String? _validateForm(AddEmployeeParams params) {
    if (params.lastName.isEmpty) return 'Last Name is required';
    if (params.firstName.isEmpty) return 'First Name is required';
    if (params.lastName.length < 2) return 'Last Name must be at least 2 characters';
    if (params.firstName.length < 2) return 'First Name must be at least 2 characters';
    return null;
  }
}