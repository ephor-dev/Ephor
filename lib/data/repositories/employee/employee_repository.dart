// data/repositories/employee/employee_repository.dart

import 'package:ephor/domain/models/employee/employee.dart';
import 'package:ephor/data/repositories/employee/abstract_employee_repository.dart';
import 'package:ephor/data/services/supabase/employee_supabase_service.dart';
import 'package:ephor/utils/results.dart';
import 'package:ephor/utils/custom_message_exception.dart'; 
import 'package:supabase_flutter/supabase_flutter.dart'; 

class EmployeeRepository implements AbstractEmployeeRepository {
  
  final EmployeeSupabaseService _employeeService;

  EmployeeRepository({required EmployeeSupabaseService employeeService})
      : _employeeService = employeeService;

  @override
  Future<Result<EmployeeModel>> addEmployee(EmployeeModel employee) async {
    try {
      final addedEmployee = await _employeeService.add(employee);
      return Result.ok(addedEmployee);
    } on PostgrestException catch (e) {
      return Result.error(CustomMessageException('Database error while adding employee: ${e.message}'));
    } catch (e) {
      return Result.error(CustomMessageException('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Result<List<EmployeeModel>>> fetchAllEmployees() async {
    try {
      final employeeList = await _employeeService.fetchAll();
      return Result.ok(employeeList);
    } on PostgrestException catch (e) {
      return Result.error(CustomMessageException('Database error while fetching employee list: ${e.message}'));
    } catch (e) {
      return Result.error(CustomMessageException('An unexpected error occurred: ${e.toString()}'));
    }
  }
  
  @override
  Future<Result<void>> removeEmployee(String id) async {
    try {
      await _employeeService.remove(id);
      return Result.ok(null);
    } on PostgrestException catch (e) {
      return Result.error(CustomMessageException('Database error while removing employee: ${e.message}'));
    } catch (e) {
      return Result.error(CustomMessageException('An unexpected error occurred: ${e.toString()}'));
    }
  }
  
  @override
  Future<Result<EmployeeModel?>> getEmployeeById(String id) async {
    try {
      final employee = await _employeeService.getById(id);
      return Result.ok(employee);
    } on PostgrestException catch (e) {
      return Result.error(CustomMessageException('Database error while fetching employee: ${e.message}'));
    } catch (e) {
      return Result.error(CustomMessageException('An unexpected error occurred: ${e.toString()}'));
    }
  }
}