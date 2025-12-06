import 'dart:async';

import 'package:ephor/data/repositories/auth/abstract_auth_repository.dart';
import 'package:ephor/data/repositories/employee/employee_repository.dart';
import 'package:ephor/domain/enums/employee_role.dart';
import 'package:ephor/domain/types/add_employee_params.dart';
import 'package:ephor/domain/use_cases/employee_model_creator.dart';
import 'package:ephor/utils/custom_message_exception.dart';
import 'package:flutter/material.dart';

import 'package:ephor/domain/models/employee/employee.dart';
import 'package:ephor/utils/command.dart';
import 'package:ephor/utils/results.dart';
import 'package:image_picker/image_picker.dart'; 

class AddEmployeeViewModel extends ChangeNotifier { 
  
  final EmployeeRepository _employeeRepository;
  final AbstractAuthRepository _authRepository;

  late CommandWithArgs addEmployee;
  late CommandNoArgs pickImage;
  late CommandNoArgs clearImage;

  AddEmployeeViewModel({
    required EmployeeRepository employeeRepository,
    required AbstractAuthRepository authRepository
  }) : _employeeRepository = employeeRepository,
      _authRepository = authRepository{
    addEmployee = CommandWithArgs<void, AddEmployeeParams>(_addEmployee);
    pickImage = CommandNoArgs(_pickImage);
    clearImage = CommandNoArgs(_clearImage);
  }

  // --- UI State (Text Controllers) ---
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController middleNameController = TextEditingController();
  final TextEditingController tagsController = TextEditingController();
  final TextEditingController emailController = TextEditingController(); // NEW
  
  // --- UI State (Selections) ---
  EmployeeRole employeeRole = EmployeeRole.personnel; 
  String? selectedDepartment = 'EE Department';
  bool noDepartment = false;
  String? photoUrl;

  final List<String> departments = <String>[
    'EE Department', 'CE Department', 'ChE Department', 'ECE Department',
    'IE Department', 'ME Department', 'IT Department',
  ];

  XFile? _localImageFile;
  XFile? get localImageFile => _localImageFile;
  
  // --- Disposable Resources ---
  @override
  void dispose() {
    lastNameController.dispose();
    firstNameController.dispose();
    middleNameController.dispose();
    tagsController.dispose();
    emailController.dispose();
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

  Future<String?> uploadImage() async {
    // 2. Call the Repository to handle the upload logic
    if (_localImageFile != null) {
      final result = await _employeeRepository.uploadEmployeePhoto(_localImageFile!);
    
      if (result case Ok(value: final publicUrl)) {
        photoUrl = publicUrl;
        return "Image uploaded successfully!";
      } else if (result case Error(error: final e)) {
        // Handle upload failure by clearing the image and showing a message
        _clearImage();
        return 'Image upload failed: $e';
      }
    }

    return null;
  }

  Future<Result<XFile?>> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? xfile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70
    );

    if ((await xfile?.length())! >= 1024 * 2000) {
      return Result.error(CustomMessageException("File too large. Maximum size is 2 MB."));
    }

    if (xfile != null) {
      _localImageFile = xfile;
      notifyListeners();
      return Result.ok(xfile);
    }

    return Result.error(CustomMessageException("Cannot open the file selected"));
  }

  Future<Result<void>> _clearImage() async {
    _localImageFile = null;
    photoUrl = null;
    notifyListeners();
    return Result.ok(null);
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
      final signUpResult = await _authRepository.signUpNewUser(
        params.email!
      );
      
      if (signUpResult case Ok(value: final id)) {
        userId = id;
      } else if (signUpResult case Error(error: final e)) {
        return Result.error(e);
      } else {
         return Result.error(CustomMessageException('User sign-up failed unexpectedly.'));
      }
    }

    if (_localImageFile != null) {
      final String? uploadResult = await uploadImage();
    
      if (uploadResult != null && uploadResult.contains("failed")) { 
        return Result.error(CustomMessageException(uploadResult));
      }
    } else {
        photoUrl = null; 
    }

    final EmployeeModel employeeToSave = createEmployeeModel(params, userId, photoUrl);
    
    try {
      final result = await _employeeRepository.addEmployee(employeeToSave);
      return result;
    } catch (e) {
      debugPrint('Unexpected error in VM command: $e');
      return Result.error(CustomMessageException('Employee DB record failed to create: ${e.toString()}'));
    }
  }
  
  String? _validateForm(AddEmployeeParams params) {
    if (params.lastName.isEmpty) return 'Last Name is required';
    if (params.firstName.isEmpty) return 'First Name is required';
    if (params.lastName.length < 2) return 'Last Name must be at least 2 characters';
    if (params.firstName.length < 2) return 'First Name must be at least 2 characters';

    final bool requiresLogin = params.employeeRole == EmployeeRole.supervisor || 
                               params.employeeRole == EmployeeRole.humanResource;

    if (requiresLogin) {
      if (params.email == null || params.email!.isEmpty) return 'Email is required for ${params.employeeRole.name} accounts.';
      if (!RegExp(r'^\S+@\S+\.\S+$').hasMatch(params.email!)) return 'Invalid email format.';
    }
    
    return null;
  }
}