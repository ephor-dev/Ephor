import 'package:ephor/domain/models/employee/employee.dart';
import 'package:ephor/utils/results.dart';
import 'package:image_picker/image_picker.dart';

abstract interface class AbstractEmployeeRepository {
  /// Fetches all employees, returning a Result to handle potential errors.
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
}