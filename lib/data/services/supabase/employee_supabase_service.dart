// data/services/supabase/employee_supabase_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ephor/domain/models/employee/employee.dart';

/// Service dedicated to low-level CRUD operations for Employee data.
class EmployeeSupabaseService {
  
  static SupabaseClient? _staticClient; 
  
  SupabaseClient get _client {
    if (_staticClient == null) {
      throw Exception(
        'Supabase not initialized. Call SupabaseService.initialize() first.',
      );
    }
    return _staticClient!;
  }

  /// Adds a new employee entry to the 'employees' table.
  Future<EmployeeModel> add(EmployeeModel employee) async {
    // Note: Assuming Supabase table name is 'employees'
    final List<Map<String, dynamic>> response = await _client
        .from('employees')
        .insert(employee.toJson())
        .select()
        .limit(1);

    return EmployeeModel.fromJson(response.first);
  }

  /// Fetches all employees from the 'employees' table.
  Future<List<EmployeeModel>> fetchAll() async {
    final List<Map<String, dynamic>> response = await _client
        .from('employees')
        .select();

    return response.map(EmployeeModel.fromJson).toList();
  }

  /// Removes employee by ID.
  Future<void> remove(String id) async {
    await _client
        .from('employees')
        .delete()
        .eq('id', id);
  }

  /// Fetches employee by ID.
  Future<EmployeeModel?> getById(String id) async {
    final Map<String, dynamic>? response = await _client
        .from('employees')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return EmployeeModel.fromJson(response);
  }
}