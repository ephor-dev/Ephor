import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ephor/domain/models/employee/employee.dart';

/// Service dedicated to low-level CRUD operations for Employee data.
class EmployeeSupabaseService {
  
  static SupabaseClient? _staticClient; 
  
  SupabaseClient get _client {
    _staticClient ??= Supabase.instance.client;
    return _staticClient!;
  }

  Future<EmployeeModel> add(EmployeeModel employee) async {
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