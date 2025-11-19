import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ephor/domain/models/employee/employee.dart'; // Ensure this model is available

/// Supabase service for handling low-level database, auth, and application-specific
/// data (like Employee CRUD) calls, serving as a single source of truth.
class SupabaseService {
  
  // Use a nullable static client, initialized only once.
  static SupabaseClient? _staticClient; 
  
  // --- Static Initialization ---
  
  /// Initializes the Supabase client instance. Must be called once before use.
  static Future<void> initialize({
    required String supabaseUrl,
    required String supabaseAnonKey,
  }) async {
    // Only initialize if not already done
    if (_staticClient == null) {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        authOptions: FlutterAuthClientOptions(
          localStorage: EmptyLocalStorage()
        )
      );
      _staticClient = Supabase.instance.client;
    }
  }

  // Get the Supabase auth instance (used by the Repository for listening)
  static GoTrueClient get auth {
    if (_staticClient == null) {
      throw Exception('Supabase not initialized. Call SupabaseService.initialize() first.');
    }
    return _staticClient!.auth;
  }

  // --- Client Access ---

  /// Provides access to the initialized SupabaseClient instance.
  SupabaseClient get _client {
    if (_staticClient == null) {
      throw Exception(
        'Supabase not initialized. Call SupabaseService.initialize() first.',
      );
    }
    return _staticClient!;
  }

  // -----------------------------------------------------------
  // --- Authentication/User Actions (from original SupabaseService) ---
  // -----------------------------------------------------------

  Future<AuthResponse> signUpWithEmail(String email, String password) async {
    final authResponse = await _client.auth.signUp(
      email: email,
      password: password,
    );
    return authResponse;
  }

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
  
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // -----------------------------------------------------------
  // --- Employee CRUD Actions (from original EmployeeSupabaseService) ---
  // -----------------------------------------------------------

  /// Inserts a new employee record and returns the created model.
  Future<EmployeeModel> addEmployee(EmployeeModel employee) async {
    final List<Map<String, dynamic>> response = await _client
        .from('employees')
        .insert(employee.toJson())
        .select()
        .limit(1);

    return EmployeeModel.fromJson(response.first);
  }

  /// Fetches all employees from the 'employees' table.
  Future<List<EmployeeModel>> fetchAllEmployees() async {
    final List<Map<String, dynamic>> response = await _client
        .from('employees')
        .select();

    return response.map(EmployeeModel.fromJson).toList();
  }

  /// Removes employee by ID.
  Future<void> removeEmployee(String id) async {
    await _client
        .from('employees')
        .delete()
        .eq('id', id);
  }

  /// Fetches employee by ID.
  Future<EmployeeModel?> getEmployeeById(String id) async {
    final Map<String, dynamic>? response = await _client
        .from('employees')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return EmployeeModel.fromJson(response);
  }

  Future<EmployeeModel?> getEmployeeByEmail(String? email) async {
    if (email == null) {
      return null;
    }

    final Map<String, dynamic>? response = await _client
        .from('employees')
        .select()
        .eq('email', email)
        .maybeSingle();
    
    if (response == null) return null;
    return EmployeeModel.fromJson(response);
  }

  // Upload employee photos
  Future<String> uploadEmployeePhoto(String path, Uint8List fileBytes) async {
    final fileName = 'employee-photos/$path'; 
    
    // Upload the file
    final _ = await _client.storage.from('employee-photos').uploadBinary(
      fileName,
      fileBytes,
      fileOptions: const FileOptions(
        upsert: true, // Overwrite if the file already exists
        contentType: 'image/jpeg',
      ),
    );
    
    // Get the public URL for the uploaded file
    final String publicUrl = _client.storage.from('employee-photos').getPublicUrl(fileName);
    
    return publicUrl;
  }

  Future<String> getSignedEmployeePhotoUrl(String path) async {
    String correctRelativePath = Uri.parse(path)
      .path 
      .split('/')
      .skipWhile((segment) => segment != "employee-photos")
      .skip(1)
      .join('/');

    final response = await _client.storage.from('employee-photos').createSignedUrl(
      correctRelativePath,
      60,
    );

    return response; // response contains the full signed URL string
  }
}