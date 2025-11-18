// data/repositories/employee/employee_repository.dart

import 'package:ephor/domain/models/employee/employee.dart';
import 'package:ephor/data/repositories/employee/abstract_employee_repository.dart';
import 'package:ephor/data/services/supabase/supabase_service.dart';
import 'package:ephor/utils/results.dart';
import 'package:ephor/utils/custom_message_exception.dart'; 
import 'package:supabase_flutter/supabase_flutter.dart'; 

class EmployeeRepository implements AbstractEmployeeRepository {
  
  final SupabaseService _supabaseService;

  EmployeeRepository({required SupabaseService employeeService})
      : _supabaseService = employeeService;

  @override
  Future<Result<String>> signUpNewUser(String email, String password) async {
    try {
      final response = await _supabaseService.signUpWithEmail(email, password);
      final userId = response.user?.id;
      
      if (userId == null) {
        // This case usually means email confirmation is required, but no session was created.
        if (response.session == null && response.user != null) {
             return Result.error(CustomMessageException('User created, but requires email confirmation.'));
        }
        return Result.error(CustomMessageException('User signup failed.'));
      }
      return Result.ok(userId);
    } on AuthException catch (e) {
      return Result.error(CustomMessageException('Authentication error: ${e.message}'));
    } catch (e) {
      return Result.error(CustomMessageException('An unexpected error occurred during sign-up: ${e.toString()}'));
    }
  }

  @override
  Future<Result<EmployeeModel>> addEmployee(EmployeeModel employee) async {
    try {
      final addedEmployee = await _supabaseService.addEmployee(employee);
      return Result.ok(addedEmployee);
    } on PostgrestException catch (e) {
      // --- RLS Violation Check Added Here ---
      final message = e.message.toLowerCase();
      if (message.contains('violates row-level security policy') || 
          message.contains('new row violates row-level security policy')) {
        return Result.error(CustomMessageException(
          'RLS Policy Violation: The current user is not authorized to add this employee. '
          'Please ensure you are logged in as an HR Manager or Admin.',
        ));
      }
      // --- End RLS Check ---
      return Result.error(CustomMessageException('Database error while adding employee: ${e.message}'));
    } catch (e) {
      return Result.error(CustomMessageException('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Result<List<EmployeeModel>>> fetchAllEmployees() async {
    try {
      final employeeList = await _supabaseService.fetchAllEmployees();
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
      await _supabaseService.removeEmployee(id);
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
      final employee = await _supabaseService.getEmployeeById(id);
      return Result.ok(employee);
    } on PostgrestException catch (e) {
      return Result.error(CustomMessageException('Database error while fetching employee: ${e.message}'));
    } catch (e) {
      return Result.error(CustomMessageException('An unexpected error occurred: ${e.toString()}'));
    }
  }
}