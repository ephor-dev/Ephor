// presentation/viewmodels/login_view_model.dart

import 'dart:async';
import 'package:ephor/data/repositories/shared_prefs/abstract_prefs_repository.dart';
import 'package:ephor/domain/models/employee/employee.dart';
import 'package:ephor/ui/core/themes/theme_mode_notifier.dart';
import 'package:ephor/utils/custom_message_exception.dart';
import 'package:ephor/utils/results.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Keep only for generic User type
import 'package:ephor/data/services/supabase/supabase_service.dart';
import 'package:ephor/data/repositories/auth/auth_repository.dart';
import 'package:ephor/utils/command.dart';
import 'package:ephor/domain/enums/auth_status.dart'; // NEW IMPORT

/// ViewModel for handling login logic. PURELY handles presentation state.
class LoginViewModel extends ChangeNotifier {
  
  final AuthRepository _authRepository;
  final AbstractPrefsRepository _prefsRepository;
  final ThemeModeNotifier _themeNotifier;
  
  // Subscriptions to the Repository streams
  late final StreamSubscription<bool> _loadingSubscription; 
  late final StreamSubscription<AuthStatus> _authStatusSubscription; 

  // --- State Properties ---
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  User? _currentUser;
  User? get currentUser => _currentUser;

  EmployeeModel? _employeeData;
  EmployeeModel? get employeeData => _employeeData;

  late CommandWithArgs login;
  late CommandWithArgs setRememberMe;

  LoginViewModel({
    required AuthRepository authRepository, 
    required AbstractPrefsRepository prefsRepository,
    required ThemeModeNotifier themeNotifier
  })
    : _authRepository = authRepository,
      _prefsRepository = prefsRepository,
      _themeNotifier = themeNotifier {
    // 1. Initialize and subscribe to ALL Repository streams
    _subscribeToLoadingStatus(); 
    _subscribeToAuthStatus();
    
    // Command setup
    login = CommandWithArgs<void, (String employeeCode, String password, String userRole)>(_loginWithCode);
    setRememberMe = CommandWithArgs<void, bool>(_setRememberMe);

    loadSavedTheme();
  }

  // --- Subscription Management ---

  void _subscribeToLoadingStatus() {
    _loadingSubscription = _authRepository.isLoadingStream.listen((isRepoLoading) {
      if (_isLoading != isRepoLoading) {
        _isLoading = isRepoLoading;
        notifyListeners();
      }
    });
  }

  void _subscribeToAuthStatus() {
    // 2. Listener for high-level authentication changes (signedIn/signedOut)
    _authStatusSubscription = _authRepository.authStatusStream.listen((status) {
      if (status == AuthStatus.signedIn) {
        // We need the concrete user object, which the Service/Client provides globally
        final user = SupabaseService.auth.currentUser;
        if (user != null) {
          _isAuthenticated = true;
          _currentUser = user;
          _errorMessage = null;
          _loadEmployeeData(user.id);
        }
      } else if (status == AuthStatus.signedOut) {
        _isAuthenticated = false;
        _currentUser = null;
        _employeeData = null;
      }
      notifyListeners();
    });
    
    // Check initial state after setting up the listener
    _checkInitialAuthState();
  }

  @override
  void dispose() {
    _loadingSubscription.cancel(); 
    _authStatusSubscription.cancel(); 
    super.dispose();
  }
  
  void _checkInitialAuthState() {
    _currentUser = SupabaseService.auth.currentUser;
    _isAuthenticated = _currentUser != null;
    if (_isAuthenticated && _currentUser != null) {
      _loadEmployeeData(_currentUser!.id);
    }
    notifyListeners();
  }
  
  // --- Data Delegation ---

  Future<void> _loadEmployeeData(String userId) async {
    try {
      final employeeDataMap = await _authRepository.getEmployeeData(userId);
      if (employeeDataMap != null) {
        _employeeData = EmployeeModel.fromJson(employeeDataMap);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading employee data: $e');
    }
  }

  // --- Command Implementation (Clean Delegation) ---

  Future<Result<void>> _loginWithCode((String, String, String) p1) async {
    final (employeeCode, password, userRole) = p1;
    _errorMessage = null; 

    final result = await _authRepository.login(
      employeeCode: employeeCode, 
      password: password, 
      userRole: userRole
    );
    
    switch (result) {
      case Ok():
        // Login was successful (Ok<void> has no value to extract)
        _errorMessage = null;
        // State updates for success are handled by the _authStatusSubscription
        break; 
        
      case Error(:final error):
        // Login failed (Error<T> has the 'error' property)
        // Since the Repository returns CustomMessageException, we use its message
        if (error is CustomMessageException) {
          _errorMessage = error.message;
        } else {
          // Fallback for unexpected exceptions
          _errorMessage = 'An unknown login error occurred: ${error.runtimeType}';
        }
        break;
    }
    
    notifyListeners(); 
    return result;
  }

  Future<Result<void>> _setRememberMe(bool setRememberMe) async {
    final result = await _prefsRepository.setKeepLoggedIn(setRememberMe);

    if (result) {
      return Result.ok(null);
    }

    return Result.error(CustomMessageException("Failed to set 'Remember Me'"));
  }

  void loadSavedTheme() async {
    final themeMode = await _prefsRepository.getThemeMode();
    _themeNotifier.setThemeMode(themeMode);
  }
}