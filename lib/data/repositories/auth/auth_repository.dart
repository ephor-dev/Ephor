// data/repositories/auth/auth_repository.dart

import 'dart:async';
import 'package:ephor/data/services/supabase/supabase_service.dart';
import 'package:ephor/utils/custom_message_exception.dart';
import 'package:ephor/utils/results.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ephor/domain/enums/auth_status.dart'; // NEW IMPORT
import 'abstract_auth_repository.dart';

class AuthRepository extends AbstractAuthRepository {
  
  final SupabaseService _supabaseService;

  // --- State Streams ---
  final _isLoadingController = StreamController<bool>.broadcast();
  final _authStateController = StreamController<AuthStatus>.broadcast(); // NEW CONTROLLER
  
  Stream<bool> get isLoadingStream => _isLoadingController.stream;
  Stream<AuthStatus> get authStatusStream => _authStateController.stream; // NEW STREAM

  AuthRepository({required SupabaseService supabaseService}) 
    : _supabaseService = supabaseService {
    _startAuthStatusListener(); // Start listening when the Repository is created
  }

  // --- Session Listener Implementation ---
  void _startAuthStatusListener() {
    // Listens to the low-level Supabase client and translates events
    SupabaseService.auth.onAuthStateChange.listen((data) {
      final event = data.event;

      if (event == AuthChangeEvent.signedIn) {
        _authStateController.add(AuthStatus.signedIn);
      } else if (event == AuthChangeEvent.signedOut) {
        _authStateController.add(AuthStatus.signedOut);
      }
    });
  }

  @override
  void dispose() {
    _isLoadingController.close();
    _authStateController.close(); // Dispose the new controller
    super.dispose();
  }

  // --- Login Business Logic ---

  @override
  Future<Result<void>> login({
    required String employeeCode,
    required String password,
    required String userRole,
    required bool rememberMe
  }) async {
    _isLoadingController.add(true); 

    try {
      if (employeeCode.isEmpty) {
        return Result.error(CustomMessageException('Employee code is required'));
      }
      if (password.isEmpty) {
        return Result.error(CustomMessageException('Password is required'));
      }

      final employeeResponse = await _supabaseService.validateEmployeeCode(employeeCode);

      if (employeeResponse == null) {
        return Result.error(CustomMessageException('Employee code not found'));
      }

      if (employeeResponse['role'] != userRole) {
        return Result.error(CustomMessageException('Invalid role for this employee'));
      }

      final email = employeeResponse['email'] as String;

      final authResponse = await _supabaseService.loginWithEmail(email, password);

      if (authResponse.user != null && authResponse.session != null) {
        await _supabaseService.updateLastLogin(authResponse.user!.id);
        return Result.ok(null);
      }
      
      return Result.error(CustomMessageException('Login failed'));

    } on AuthException catch (e) {
      final message = e.message.toLowerCase();
      if (message.contains('invalid login') || message.contains('invalid credentials')) {
        return Result.error(CustomMessageException('Invalid email or password. Please try again.'));
      }
      return Result.error(CustomMessageException(e.message));
    } on PostgrestException catch (e) {
      return Result.error(CustomMessageException('Database error: ${e.message}'));
    } catch (e) {
      return Result.error(CustomMessageException('An unexpected error occurred: ${e.toString()}'));
    } finally {
      _isLoadingController.add(false); 
    }
  }

  // --- Data Fetching ---
  
  Future<Map<String, dynamic>?> getEmployeeData(String userId) async {
    return await _supabaseService.getEmployeeData(userId);
  }
  
  @override
  Future<bool> get isAuthenticated async {
      // Use the low-level SupabaseService to check the current session status
      final currentUser = SupabaseService.auth.currentUser;
      
      // Return true if a user object exists in the Supabase session, false otherwise.
      return currentUser != null; 
  }
  
  @override
  Future<Result<void>> logout() async {
    await _supabaseService.signOut();
    return Result.ok(null);
  }
}