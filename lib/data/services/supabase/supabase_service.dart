// data/services/supabase/supabase_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase service for handling low-level database and auth calls.
class SupabaseService {
  
  static SupabaseClient? _staticClient; 
  
  SupabaseClient get _client {
    if (_staticClient == null) {
      throw Exception(
        'Supabase not initialized. Call SupabaseService.initialize() first.',
      );
    }
    return _staticClient!;
  }

  // --- Static Initialization (Kept for pragmatic Flutter setup) ---

  static Future<void> initialize({
    required String supabaseUrl,
    required String supabaseAnonKey,
  }) async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
    _staticClient = Supabase.instance.client;
  }

  // Get the Supabase auth instance (used by the Repository for listening)
  static GoTrueClient get auth => _staticClient!.auth; 

  // --- Authentication/Database Actions (Instance methods) ---

  Future<AuthResponse> loginWithEmail(String email, String password) async {
    final authResponse = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return authResponse;
  }
  
  Future<Map<String, dynamic>?> validateEmployeeCode(String employeeCode) async {
    final employeeResponse = await _client
        .from('employees') 
        .select('email, role, employee_code, id, first_name, last_name')
        .eq('employee_code', employeeCode)
        .maybeSingle();

    final employee_list = await _client.from("employees").select();
    print(employee_list);
    
    return employeeResponse;
  }

  Future<Map<String, dynamic>?> getEmployeeData(String userId) async {
    final response = await _client
        .from('employees')
        .select()
        .eq('id', userId)
        .maybeSingle();

    return response;
  }

  Future<void> updateLastLogin(String userId) async {
    await _client
        .from('employees')
        .update({'last_login': DateTime.now().toIso8601String()})
        .eq('id', userId);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}