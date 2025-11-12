import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ephor/data/services/supabase/supabase_service.dart';
import 'package:ephor/domain/models/login/employee.dart';
import 'package:ephor/domain/models/login/login_request.dart';
import 'package:ephor/domain/models/login/login_response.dart';

/// ViewModel for handling login logic with Supabase authentication and database
class LoginViewModel extends ChangeNotifier {
  final SupabaseClient _supabase = SupabaseService.client;

  // Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Error message
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Authentication state
  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  // Current user
  User? _currentUser;
  User? get currentUser => _currentUser;

  // Current employee data
  EmployeeModel? _employeeData;
  EmployeeModel? get employeeData => _employeeData;

  LoginViewModel() {
    _initializeAuthState();
  }

  /// Initialize and listen to auth state changes
  void _initializeAuthState() {
    _checkAuthState();
    
    // Listen to auth state changes
    _supabase.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      if (event == AuthChangeEvent.signedIn && session != null) {
        _isAuthenticated = true;
        _currentUser = session.user;
        _errorMessage = null;
        _loadEmployeeData(session.user.id);
        notifyListeners();
      } else if (event == AuthChangeEvent.signedOut) {
        _isAuthenticated = false;
        _currentUser = null;
        _employeeData = null;
        notifyListeners();
      }
    });
  }

  /// Check current authentication state
  void _checkAuthState() {
    _currentUser = _supabase.auth.currentUser;
    _isAuthenticated = _currentUser != null;
    if (_isAuthenticated && _currentUser != null) {
      _loadEmployeeData(_currentUser!.id);
    }
    notifyListeners();
  }

  /// Load employee data from database
  Future<void> _loadEmployeeData(String userId) async {
    try {
      final employeeData = await getUserData(userId);
      if (employeeData != null) {
        _employeeData = EmployeeModel.fromJson(employeeData);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading employee data: $e');
    }
  }

  /// Sign in with employee code and password
  /// 
  /// AUTHENTICATION FLOW:
  /// 1. Lookup employee by employee_code in your 'employees' table (database query)
  /// 2. Retrieve the email associated with that employee_code
  /// 3. Verify password using Supabase Auth (checks auth.users table)
  /// 
  /// NOTE: Passwords are NOT stored in your employees table!
  /// Passwords are stored securely in Supabase's auth.users table.
  Future<LoginResponse> signInWithEmployeeCode(LoginRequest request) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // ===== STEP 1: Input Validation =====
      // Validate that user provided both employee code and password
      if (request.employeeCode.isEmpty) {
        _isLoading = false;
        _errorMessage = 'Employee code is required';
        notifyListeners();
        return LoginResponse.failure(errorMessage: _errorMessage!);
      }

      if (request.password.isEmpty) {
        _isLoading = false;
        _errorMessage = 'Password is required';
        notifyListeners();
        return LoginResponse.failure(errorMessage: _errorMessage!);
      }

      // ===== STEP 2: Database Lookup =====
      // Query YOUR employees table to find employee by employee_code
      // This does NOT verify the password - it only retrieves the email
      // Passwords are NOT stored in the employees table!
      final employeeResponse = await _supabase
          .from('employees') // Your custom table name
          .select('email, role, employee_code, id, first_name, last_name')
          .eq('employee_code', request.employeeCode)
          .maybeSingle();

      // If employee_code doesn't exist in employees table, fail early
      if (employeeResponse == null) {
        _isLoading = false;
        _errorMessage = 'Employee code not found';
        notifyListeners();
        return LoginResponse.failure(errorMessage: _errorMessage!);
      }

      // ===== STEP 2.5: Role Validation =====
      // Optional: Verify that the employee's role matches the selected role
      // This adds an extra layer of security
      if (request.userRole != null && 
          employeeResponse['role'] != request.userRole!.value) {
        _isLoading = false;
        _errorMessage = 'Invalid role for this employee';
        notifyListeners();
        return LoginResponse.failure(errorMessage: _errorMessage!);
      }

      // Extract email from database result
      final email = employeeResponse['email'] as String;

      // ===== STEP 3: Supabase Auth Verification =====
      // THIS IS WHERE THE PASSWORD IS ACTUALLY CHECKED!
      // Supabase Auth verifies:
      // 1. Email exists in auth.users table
      // 2. Password hash matches (uses secure bcrypt hashing)
      // 3. Account is active and not disabled
      // 
      // If successful, Supabase returns:
      // - User object (with id, email, metadata)
      // - Session object (with access_token, refresh_token JWT tokens)
      final authResponse = await _supabase.auth.signInWithPassword(
        email: email,              // Retrieved from employees table
        password: request.password, // User-entered password
      );

      if (authResponse.user != null && authResponse.session != null) {
        // Load employee data
        _employeeData = EmployeeModel.fromJson(employeeResponse);

        // Optionally update last login timestamp in database
        await _updateLastLogin(authResponse.user!.id);

        _isAuthenticated = true;
        _currentUser = authResponse.user;
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();

        return LoginResponse.success(
          user: authResponse.user!,
          session: authResponse.session!,
          employeeData: _employeeData,
        );
      }

      _isLoading = false;
      _errorMessage = 'Login failed';
      notifyListeners();
      return LoginResponse.failure(errorMessage: _errorMessage!);
    } catch (e) {
      _isLoading = false;
      _errorMessage = _extractErrorMessage(e);
      notifyListeners();
      return LoginResponse.failure(errorMessage: _errorMessage!);
    }
  }

  /// Sign in with email and password (alternative method)
  /// 
  /// DIRECT AUTHENTICATION FLOW:
  /// This method bypasses the employee_code lookup and goes straight to Supabase Auth.
  /// Use this when you have the email directly (e.g., forgot employee code).
  /// 
  /// Password verification happens in Supabase's auth.users table.
  Future<LoginResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Direct Supabase Auth verification
      // Checks auth.users table for matching email + password
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null && response.session != null) {
        await _loadEmployeeData(response.user!.id);
        
        _isAuthenticated = true;
        _currentUser = response.user;
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();

        return LoginResponse.success(
          user: response.user!,
          session: response.session!,
          employeeData: _employeeData,
        );
      }

      _isLoading = false;
      _errorMessage = 'Login failed';
      notifyListeners();
      return LoginResponse.failure(errorMessage: _errorMessage!);
    } catch (e) {
      _isLoading = false;
      _errorMessage = _extractErrorMessage(e);
      notifyListeners();
      return LoginResponse.failure(errorMessage: _errorMessage!);
    }
  }

  /// Update last login timestamp in database
  Future<void> _updateLastLogin(String userId) async {
    try {
      await _supabase
          .from('employees')
          .update({'last_login': DateTime.now().toIso8601String()})
          .eq('id', userId);
    } catch (e) {
      // Log error but don't fail the login process
      debugPrint('Error updating last login: $e');
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _supabase.auth.signOut();

      _isAuthenticated = false;
      _currentUser = null;
      _employeeData = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = _extractErrorMessage(e);
      notifyListeners();
    }
  }

  /// Get user data from database
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final response = await _supabase
          .from('employees') // Adjust table name as needed
          .select()
          .eq('id', userId)
          .maybeSingle();

      return response as Map<String, dynamic>?;
    } catch (e) {
      _errorMessage = _extractErrorMessage(e);
      notifyListeners();
      return null;
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Extract error message from exception
  String _extractErrorMessage(dynamic error) {
    if (error is AuthException) {
      // Provide user-friendly messages for common auth errors
      final message = error.message.toLowerCase();
      if (message.contains('email not confirmed') || 
          message.contains('email_confirmed_at') ||
          message.contains('confirm')) {
        return 'Email not confirmed. Please confirm your email or contact administrator.';
      } else if (message.contains('invalid login') || 
                 message.contains('invalid credentials')) {
        return 'Invalid email or password. Please try again.';
      } else if (message.contains('user not found')) {
        return 'No account found with this email.';
      }
      return error.message;
    } else if (error is PostgrestException) {
      return error.message;
    } else if (error is Exception) {
      return error.toString();
    }
    return 'An unexpected error occurred';
  }
}
