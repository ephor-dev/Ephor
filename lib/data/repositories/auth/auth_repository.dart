import 'dart:async';
import 'package:ephor/data/services/supabase/supabase_service.dart';
import 'package:ephor/domain/models/employee/employee.dart';
import 'package:ephor/utils/custom_message_exception.dart';
import 'package:ephor/utils/results.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ephor/domain/enums/auth_status.dart';
import 'abstract_auth_repository.dart';

class AuthRepository extends AbstractAuthRepository {
  
  final SupabaseService _supabaseService;

  // --- State Streams ---
  final _isLoadingController = StreamController<bool>.broadcast();
  final _authStateController = StreamController<AuthStatus>.broadcast();
  
  Stream<bool> get isLoadingStream => _isLoadingController.stream;
  Stream<AuthStatus> get authStatusStream => _authStateController.stream;

  EmployeeModel? _currentUser;
  @override
  EmployeeModel? get currentUser => _currentUser;

  bool isPasswordRecoveryMode = false;

  AuthRepository({required SupabaseService supabaseService}) 
    : _supabaseService = supabaseService {
    _startAuthStatusListener();
  }

  // --- Session Listener Implementation ---
  void _startAuthStatusListener() async {
    if (SupabaseService.auth.currentUser != null) {
      _authStateController.add(AuthStatus.signedIn);
      _currentUser = await getAuthenticatedUserData();
    }

    SupabaseService.auth.onAuthStateChange.listen((data) async {
      final event = data.event;

      if (event == AuthChangeEvent.passwordRecovery) {
        isPasswordRecoveryMode = true;
        _authStateController.add(AuthStatus.signedIn); 
      } else if (event == AuthChangeEvent.signedIn) {
        _authStateController.add(AuthStatus.signedIn);
        _currentUser = await getAuthenticatedUserData();
      } else if (event == AuthChangeEvent.signedOut) {
        isPasswordRecoveryMode = false; // Reset flag
        _authStateController.add(AuthStatus.signedOut);
      } else if (event == AuthChangeEvent.userUpdated) {
        _currentUser = await getAuthenticatedUserData();
      }

      notifyListeners();
    });
  }

  @override
  void dispose() {
    _isLoadingController.close();
    _authStateController.close();
    super.dispose();
  }

  // --- Login Business Logic ---

  @override
  Future<Result<void>> login({
    required String employeeCode,
    required String password,
    required String userRole
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

      if (employeeResponse['role'] != 'humanResource'
       && employeeResponse['role'] != 'supervisor') {
        return Result.error(CustomMessageException("Only HR and Supervisor can use Ephor."));
      }

      if (employeeResponse['role'] != userRole) {
        return Result.error(CustomMessageException('Invalid role for this employee'));
      }

      final email = employeeResponse['email'] as String;

      final authResponse = await _supabaseService.loginWithEmail(email, password);

      if (authResponse.user != null && authResponse.session != null) {
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
      final currentUser = SupabaseService.auth.currentUser;
      return currentUser != null; 
  }
  
  @override
  Future<Result<void>> logout() async {
    await _supabaseService.signOut();
    return Result.ok(null);
  }
  
  Future<EmployeeModel?> getAuthenticatedUserData() async {
    final currentUser = SupabaseService.auth.currentUser;
    if (currentUser == null) {
      return null;
    }

    EmployeeModel? employeeModel = await _supabaseService.getEmployeeByEmail(currentUser.email);
    return employeeModel;
  }

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
  Future<Result<void>> changePassword(String newPassword) async {
    _isLoadingController.add(true);
    try {
      await _supabaseService.changePassword(newPassword);
      
      // Reset the recovery flag since they successfully changed it
      isPasswordRecoveryMode = false; 
      
      return Result.ok(null);
    } on AuthException catch (e) {
      return Result.error(CustomMessageException(e.message));
    } catch (e) {
      return Result.error(CustomMessageException('Error updating password: $e'));
    } finally {
      _isLoadingController.add(false);
    }
  }

  @override
  Future<Result<void>> changeEmail(String newEmail) async {
    _isLoadingController.add(true);
    try {
      await _supabaseService.changeEmail(newEmail);   
      return Result.ok(null);
    } on AuthException catch (e) {
      return Result.error(CustomMessageException(e.message));
    } catch (e) {
      return Result.error(CustomMessageException('Error updating email: $e'));
    } finally {
      _isLoadingController.add(false);
    }
  }

  @override
  Future<Result<void>> checkPassword(String password) async {
    _isLoadingController.add(true);
    try {
      await _supabaseService.checkPassword(password);
      
      return Result.ok(null);
    } on AuthException catch (e) {
      return Result.error(CustomMessageException(e.message));
    } catch (e) {
      return Result.error(CustomMessageException('Password mismatch: $e'));
    } finally {
      _isLoadingController.add(false);
    }
  }

  @override
  Future<Result<void>> sendPasswordResetEmail(String passCode) async {
    _isLoadingController.add(true);
    try {
      // 1. Find email from Employee Code
      final employeeResponse = await _supabaseService.validateEmployeeCode(passCode);
      
      if (employeeResponse == null) {
        return Result.error(CustomMessageException('Employee Code not found.'));
      }

      final email = employeeResponse['email'] as String?;
      if (email == null || email.isEmpty) {
        return Result.error(CustomMessageException('No email found for this employee.'));
      }

      // 2. Send Supabase Reset Email
      await _supabaseService.resetPasswordForEmail(email);
      return Result.ok(null);

    } on AuthException catch (e) {
      return Result.error(CustomMessageException(e.message));
    } catch (e) {
      return Result.error(CustomMessageException('Unknown error: $e'));
    } finally {
      _isLoadingController.add(false);
    }
  }

  @override
  Future<Result<String?>> getAuthenticatedUserImage(EmployeeModel? currentUser) async {
    String? signedUrl;
    if (currentUser != null) {
      signedUrl = await _supabaseService.getSignedEmployeePhotoUrl(currentUser.photoUrl);
      return Result.ok(signedUrl);
    }

    return Result.error(CustomMessageException("Cannot get the User Image"));
  }
}