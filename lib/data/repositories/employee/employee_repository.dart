// data/repositories/employee/employee_repository.dart

import 'dart:io';

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
  Future<Result<String>> uploadEmployeePhoto(File file) async {
    try {
        final fileBytes = await file.readAsBytes();
        final uniqueId = 'employee-${DateTime.now().millisecondsSinceEpoch}-${file.uri.pathSegments.last}';
        final publicUrl = await _supabaseService.uploadEmployeePhoto(uniqueId, fileBytes);
        
        return Result.ok(publicUrl);
    } on StorageException catch (e) {
      return Result.error(CustomMessageException('Image upload failed: ${e.message}'));
    } catch (e) {
      return Result.error(CustomMessageException('An unexpected error occurred during photo upload: ${e.toString()}'));
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
      final List<EmployeeModel> employeesWithSignedUrls = [];
      for (var employee in employeeList) {
        if (employee.photoUrl != null) {
          final signedUrl = await _supabaseService.getSignedEmployeePhotoUrl(employee.photoUrl!);
          
          // Create a new model instance with the temporary signed URL
          final updatedEmployee = employee.copyWith(photoUrl: signedUrl);
          employeesWithSignedUrls.add(updatedEmployee);
        } else {
          employeesWithSignedUrls.add(employee);
        }
      }

      return Result.ok(employeesWithSignedUrls);
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