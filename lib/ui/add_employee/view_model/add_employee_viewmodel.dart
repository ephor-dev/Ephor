// ui/add_employee/view_model/add_employee_viewmodel.dart

import 'dart:math';

import 'package:ephor/data/repositories/employee/abstract_employee_repository.dart';
import 'package:ephor/utils/custom_message_exception.dart';
import 'package:flutter/material.dart';

import 'package:ephor/domain/models/employee/employee.dart';
import 'package:ephor/utils/command.dart';
import 'package:ephor/utils/results.dart'; 

/// Parameter type for the Command: Email and Password are conditionally required.
typedef AddEmployeeParams = ({
  String lastName,
  String firstName,
  String middleName,
  String? email, // Now conditionally required
  String? password, // Now conditionally required
  EmployeeRole employeeRole, 
  String? department,
  String tags,
  String? photoUrl,
});

class AddEmployeeViewModel extends ChangeNotifier { 
  
  final AbstractEmployeeRepository _repository;
  late CommandWithArgs addEmployee;

  AddEmployeeViewModel({required AbstractEmployeeRepository repository})
    : _repository = repository {
    addEmployee = CommandWithArgs<void, AddEmployeeParams>(_addEmployee);
  }

  // --- UI State (Text Controllers) ---
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController middleNameController = TextEditingController();
  final TextEditingController tagsController = TextEditingController();
  final TextEditingController emailController = TextEditingController(); // NEW
  final TextEditingController passwordController = TextEditingController(); // NEW
  
  // --- UI State (Selections) ---
  EmployeeRole employeeRole = EmployeeRole.personnel; 
  String? selectedDepartment = 'EE Department';
  bool noDepartment = false;
  String? photoUrl;

  final List<String> departments = <String>[
    'EE Department', 'CE Department', 'ChE Department', 'ECE Department',
    'IE Department', 'ME Department', 'IT Department',
  ];
  
  // --- Disposable Resources ---
  @override
  void dispose() {
    lastNameController.dispose();
    firstNameController.dispose();
    middleNameController.dispose();
    tagsController.dispose();
    emailController.dispose(); 
    passwordController.dispose(); 
    super.dispose();
  }
  
  // --- Mutator Callbacks for UI interaction ---
  
  void setEmployeeRole(EmployeeRole role) {
    employeeRole = role;
    
    // 🔑 RULE 1: If HR, auto-set noDepartment to true.
    if (role == EmployeeRole.humanResource) {
      setNoDepartment(true);
    } else if (noDepartment == true) {
      // If switching away from HR, allow department choice again
      setNoDepartment(false);
    }
    
    // Reset login fields if switching away from login-required roles
    final requiresLogin = role == EmployeeRole.supervisor || role == EmployeeRole.humanResource;
    if (!requiresLogin) {
      emailController.clear();
      passwordController.clear();
    }

    notifyListeners();
  }

  void setNoDepartment(bool value) {
    noDepartment = value;
    if (noDepartment) {
      selectedDepartment = null;
    } else if (selectedDepartment == null && departments.isNotEmpty) {
      selectedDepartment = departments.first;
    }
    notifyListeners();
  }

  void setDepartment(String? value) {
    selectedDepartment = value;
    notifyListeners();
  }
  
  // --- Core Command Implementation ---

  Future<Result<EmployeeModel>> _addEmployee(AddEmployeeParams params) async {
    final String? validationError = _validateForm(params);
    if (validationError != null) {
      return Result.error(CustomMessageException(validationError));
    }
    
    String? userId;
    // 🔑 NEW LOGIC: Only perform Supabase Auth sign-up if the role requires login access
    final bool requiresLogin = params.employeeRole == EmployeeRole.supervisor || 
                               params.employeeRole == EmployeeRole.humanResource;

    if (requiresLogin) {
      // Use non-nullable fields here, as they were validated in _validateForm
      final signUpResult = await _repository.signUpNewUser(
        params.email!, 
        params.password!,
      );
      
      if (signUpResult case Ok(value: final id)) {
        userId = id;
      } else if (signUpResult case Error(error: final e)) {
        return Result.error(e);
      } else {
         return Result.error(CustomMessageException('User sign-up failed unexpectedly.'));
      }
    }

    final EmployeeModel employeeToSave = _createEmployeeModel(params, userId);
    
    try {
      final result = await _repository.addEmployee(employeeToSave);
      return result;
    } catch (e) {
      debugPrint('Unexpected error in VM command: $e');
      return Result.error(CustomMessageException('Employee DB record failed to create: ${e.toString()}'));
    }
  }

  // --- Helper Methods ---
  
  EmployeeModel _createEmployeeModel(AddEmployeeParams params, String? userId) {
    final List<String> tagList = params.tags
        .split(',')
        .map((String e) => e.trim())
        .where((String e) => e.isNotEmpty)
        .toList(growable: false);

    String rolePrefix;
    switch (params.employeeRole) {
      case EmployeeRole.supervisor:
        rolePrefix = 's-';
        break;
      case EmployeeRole.humanResource:
        rolePrefix = 'hr-';
        break;
      case EmployeeRole.personnel:
        rolePrefix = 'p-';
        break;
      case EmployeeRole.faculty:
        rolePrefix = 'f-';
        break;
      case EmployeeRole.jobOrder:
        rolePrefix = 'jo-';
        break;
    }

    final now = DateTime.now();
    final randomPart = Random().nextInt(90000) + 10000;
    final timePart = now.second.toString().padLeft(2, '0');

    // Final code format: ROLE-#####SS (e.g., hr-1234560)
    final String employeeCode = '$rolePrefix$randomPart$timePart';
    // Use the Supabase Auth ID if available, otherwise use null
    return EmployeeModel(
      id: userId, 
      employeeCode: employeeCode, 
      email: params.email ?? 'N/A', // Set email to N/A if not provided
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

    // 🔑 CONDITIONAL VALIDATION: Check for email/password ONLY if login is required
    final bool requiresLogin = params.employeeRole == EmployeeRole.supervisor || 
                               params.employeeRole == EmployeeRole.humanResource;

    if (requiresLogin) {
      if (params.email == null || params.email!.isEmpty) return 'Email is required for ${params.employeeRole.name} accounts.';
      if (!RegExp(r'^\S+@\S+\.\S+$').hasMatch(params.email!)) return 'Invalid email format.';
      if (params.password == null || params.password!.length < 6) return 'Password must be at least 6 characters for login accounts.';
    }
    
    return null;
  }
}