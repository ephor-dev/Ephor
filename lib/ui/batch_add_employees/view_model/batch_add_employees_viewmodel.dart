import 'dart:convert';
import 'dart:io';

import 'package:ephor/data/repositories/auth/abstract_auth_repository.dart';
import 'package:ephor/data/repositories/employee/abstract_employee_repository.dart';
import 'package:ephor/domain/enums/employee_role.dart';
import 'package:ephor/domain/models/employee/employee.dart';
import 'package:ephor/domain/types/add_employee_params.dart';
import 'package:ephor/domain/use_cases/csv_data_mapper.dart';
import 'package:ephor/domain/use_cases/employee_model_creator.dart';
import 'package:ephor/utils/command.dart';
import 'package:ephor/utils/custom_message_exception.dart';
import 'package:ephor/utils/results.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';

class BatchAddEmployeesViewModel extends ChangeNotifier {
  final AbstractEmployeeRepository _employeeRepository;
  final AbstractAuthRepository _authRepository;

  final List<String> _errorMessages = [];
  List<String> get errorMessages => _errorMessages;

  late CommandWithArgs addEmployees;
  late CommandNoArgs pickCSV;
  late CommandWithArgs loadCSV;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int _addProgress = 0;
  int get addProgress => _addProgress;

  BatchAddEmployeesViewModel({
    required AbstractEmployeeRepository employeeRepository,
    required AbstractAuthRepository authRepository
  }) : _employeeRepository = employeeRepository,
      _authRepository = authRepository{
    addEmployees = CommandWithArgs<void, List<EmployeeModel>>(_addEmployees);
    pickCSV = CommandNoArgs(_pickCSV);
    loadCSV = CommandWithArgs<List<EmployeeModel>, String>(_loadCSVEmployees);
  }

  Future<Result<dynamic>> _addEmployees(List<EmployeeModel> employeeList) async {
    setLoading(true);
    _addProgress = 0;
    _errorMessages.clear();
    notifyListeners();

    for (EmployeeModel employee in employeeList) {
      _addProgress++;
      notifyListeners();
      final bool requiresLogin = employee.role == EmployeeRole.supervisor || 
                                 employee.role == EmployeeRole.humanResource;

                                // Only send non-null values if login is required
      final String? email = requiresLogin ? employee.email : null;
      final String password = "ephor_app";
      
      AddEmployeeParams params = (
        lastName: employee.lastName,
        firstName: employee.firstName,
        middleName: employee.middleName ?? '',
        email: email, 
        password: password,
        employeeRole: employee.role,
        department: employee.department,
        tags: employee.extraTags.join(','),
        photoUrl: null as String?,
      );

      String? userId;

      if (requiresLogin) {
        final signUpResult = await _authRepository.signUpNewUser(
          params.email!, 
          params.password!,
        );
        
        if (signUpResult case Ok(value: final id)) {
          userId = id;
        } else if (signUpResult case Error(error: final e)) {
          _errorMessages.add('Sign-up failed for ${employee.fullName}: $e');
          continue;
        } else {
          _errorMessages.add('Sign-up failed for ${employee.fullName}');
          continue;
        }
      }

      final EmployeeModel employeeToSave = createEmployeeModel(params, userId, null);
      
      try {
        await _employeeRepository.addEmployee(employeeToSave);
      } catch (e) {
        _errorMessages.add('DB record failed for ${employee.fullName}: $e');
          continue;
      }
    }

    if (_errorMessages.isNotEmpty) {
      setLoading(false);
      return Result.error(CustomMessageException('Batch completed with ${_errorMessages.length} errors.'));
    }

    setLoading(false);
    return const Result.ok("Successfully Added Employees");
  }

  Future<Result<String>> _pickCSV() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final fileData = result.files.single;

        String fileContent;

        if (kIsWeb) {
          if (fileData.bytes == null) {
              return Result.error(CustomMessageException("Web file data bytes were null."));
          }
          fileContent = utf8.decode(fileData.bytes!);
        } else {
          if (fileData.path == null) {
              return Result.error(CustomMessageException("Desktop/Mobile file path was null."));
          }

          File file = File(fileData.path!);
          try {
            fileContent = await file.readAsString(encoding: latin1);
          } catch (e) {
            fileContent = await file.readAsString(encoding: utf8);
            fileContent = await file.readAsString(encoding: latin1);
          }
        }

        return Result.ok(fileContent); 
      }

      return Result.error(CustomMessageException("File picking cancelled by user"));

    } catch (e) {
      if (kDebugMode) {
        print('Error picking file: $e');
      }
      return Result.error(CustomMessageException("Error picking file: ${e.runtimeType}"));
    }
  }

  Future<Result<List<EmployeeModel>>> _loadCSVEmployees(String csvData) async {
    setLoading(true);
    final employeeList = CsvEmployeeMapper.mapCsvToEmployees(csvData);

    if (employeeList.isEmpty) {
      setLoading(false);
      return Result.error(CustomMessageException("Empty List"));
    }

    setLoading(false);
    return Result.ok(employeeList);
  }
  
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}