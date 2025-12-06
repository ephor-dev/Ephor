// ui/add_employee/view_model/add_employee_viewmodel.dart

import 'dart:async';

import 'package:ephor/data/repositories/employee/employee_repository.dart';
import 'package:ephor/domain/enums/employee_role.dart';
import 'package:ephor/utils/custom_message_exception.dart';
import 'package:flutter/material.dart';

import 'package:ephor/domain/models/employee/employee.dart';
import 'package:ephor/utils/command.dart';
import 'package:ephor/utils/results.dart';
import 'package:image_picker/image_picker.dart'; 

typedef EditEmployeeParams = ({
  String lastName,
  String firstName,
  String middleName,
  EmployeeRole employeeRole, 
  String? department,
  String tags,
  String? photoUrl,
});

class EditEmployeeViewModel extends ChangeNotifier { 
  
  final EmployeeRepository _employeeRepository;
  final bool fromUser;
  final String employeeCode;

  late CommandWithArgs editEmployee;
  late CommandNoArgs pickImage;
  late CommandNoArgs clearImage;

  EmployeeModel? _targetUser;
  EmployeeModel? get targetUser => _targetUser;

  EditEmployeeViewModel({
    required EmployeeRepository employeeRepository,
    required bool fromUserQuery,
    required String targetEmployeeCode
  }) : _employeeRepository = employeeRepository,
      fromUser = fromUserQuery,
      employeeCode = targetEmployeeCode {
    editEmployee = CommandWithArgs<void, EditEmployeeParams>(_editEmployee);
    pickImage = CommandNoArgs(_pickImage);
    clearImage = CommandNoArgs(_clearImage);

    loadUserInfos();
  }

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

  XFile? _localImageFile;
  XFile? get localImageFile => _localImageFile;
  
  // --- Disposable Resources ---
  @override
  void dispose() {
    lastNameController.dispose();
    firstNameController.dispose();
    middleNameController.dispose();
    tagsController.dispose();
    super.dispose();
  }
  
  void setEmployeeRole(EmployeeRole role) {
    employeeRole = role;
    if (role == EmployeeRole.humanResource) {
      setNoDepartment(true);
    } else if (noDepartment == true) {
      setNoDepartment(false);
    }

    notifyListeners();
  }

  void loadUserInfos () async {
    final result = await _employeeRepository.getEmployeeByCode(employeeCode);

    if (result case Ok(value: final employee)) {
      _targetUser = employee;
      
      // Sync UI State
      employeeRole = employee!.role;
      if (employee.department == 'N/A') {
        setNoDepartment(true);
      } else {
        setNoDepartment(false);
        if (departments.contains(employee.department)) {
            selectedDepartment = employee.department;
        }
      }
      notifyListeners(); 
    } else if (result case Error()) {
      _clearImage();
    }
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
    if (_localImageFile != null) {
      final result = await _employeeRepository.uploadEmployeePhoto(_localImageFile!);
    
      if (result case Ok(value: final publicUrl)) {
        photoUrl = publicUrl;
        return "Image uploaded successfully!";
      } else if (result case Error(error: final e)) {
        _clearImage();
        return 'Image upload failed: $e';
      }
    }

    return null;
  }

  Future<Result<XFile?>> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? xfile = await picker.pickImage(source: ImageSource.gallery);

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

  Future<Result<dynamic>> _editEmployee(EditEmployeeParams params) async {
    if (_localImageFile != null) {
      final String? uploadResult = await uploadImage();
      if (uploadResult != null && uploadResult.contains("failed")) { 
        return Result.error(CustomMessageException(uploadResult));
      }
    }

    final EmployeeModel employeeToSave = _createEmployeeModel(params, photoUrl);

    if (photoUrl != null && _targetUser?.photoUrl != null && photoUrl != _targetUser?.photoUrl) {
      var deleteResult = await deleteOldPhoto(_targetUser?.photoUrl);

      if (deleteResult case Error(: final error)) {
        return Result.error(error);
      }
    }
    
    try {
      final result = await _employeeRepository.editEmployee(employeeToSave);
      return result;
    } catch (e) {
      debugPrint('Unexpected error in VM command: $e');
      return Result.error(CustomMessageException('Employee DB record failed to edit: ${e.toString()}'));
    }
  }

  // --- Helper Methods ---
  
  EmployeeModel _createEmployeeModel(EditEmployeeParams params, String? photoUrl) {
    final List<String> tagList = params.tags
        .split(',')
        .map((String e) => e.trim())
        .where((String e) => e.isNotEmpty)
        .toList(growable: false);

    // We always keep the existing email, or default to N/A if somehow missing
    final String existingEmail = _targetUser?.email ?? 'N/A';
    
    final newModel = _targetUser?.copyWith(
      lastName: params.lastName.isEmpty ? _targetUser?.lastName : params.lastName,
      firstName: params.firstName.isEmpty ? _targetUser?.firstName : params.firstName,
      middleName: params.middleName.isEmpty ? _targetUser?.middleName : params.middleName,
      email: existingEmail,
      
      role: params.employeeRole,
      department: (params.department == null || params.department!.isEmpty)
          ? _targetUser?.department
          : params.department,
      extraTags: tagList.isEmpty ? _targetUser?.extraTags : tagList,
      photoUrl: photoUrl ?? _targetUser?.photoUrl,
    );

    return newModel!;
  }

  Future<Result> deleteOldPhoto(String? oldPhotoUrl) async {
    try {
      final result = await _employeeRepository.deleteOldPhoto(oldPhotoUrl!);
      return result;
    } catch (e) {
      debugPrint('Unexpected error in VM command: $e');
      return Result.error(CustomMessageException('Employee DB record failed to edit: ${e.toString()}'));
    }
  }
}