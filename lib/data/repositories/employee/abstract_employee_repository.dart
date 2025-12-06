import 'package:ephor/domain/models/employee/employee.dart';
import 'package:ephor/utils/results.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

abstract class AbstractEmployeeRepository extends ChangeNotifier{
  /// Fetches all employees, returning a Result to handle potential errors.
  ValueNotifier<String?> get searchKeyword;
  Future<Result<List<EmployeeModel>>> fetchAllEmployees();
  
  /// Adds a new employee entry.
  Future<Result<EmployeeModel>> addEmployee(EmployeeModel employee);
  Future<Result<EmployeeModel>> editEmployee(EmployeeModel employee);
  
  /// Removes employee by ID.
  Future<Result<void>> removeEmployee(String id);
  
  /// Fetches employee by ID.
  Future<Result<EmployeeModel?>> getEmployeeById(String id);
  Future<Result<EmployeeModel?>> getEmployeeByCode(String code);

  Future<Result<String>> uploadEmployeePhoto(XFile file);
  Future<Result<String>> deleteOldPhoto(String path);
  Future<Result<void>> setSearchKeyword(String? keyword);
}