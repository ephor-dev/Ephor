import 'dart:async';

import 'package:ephor/data/repositories/auth/auth_repository.dart';
import 'package:ephor/data/repositories/employee/employee_repository.dart';
import 'package:ephor/data/repositories/form/form_repository.dart';
import 'package:ephor/data/repositories/shared_prefs/abstract_prefs_repository.dart';
import 'package:ephor/domain/enums/auth_status.dart';
import 'package:ephor/domain/models/employee/employee.dart';
import 'package:ephor/ui/core/themes/theme_mode_notifier.dart';
import 'package:ephor/utils/command.dart';
import 'package:ephor/utils/custom_message_exception.dart';
import 'package:ephor/utils/results.dart';
import 'package:flutter/material.dart';

class DashboardViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  ValueNotifier<bool> get isAnalysisRunning => _formRepository.isAnalysisRunning;

  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  final ThemeModeNotifier _themeNotifier;

  final ValueNotifier<EmployeeModel?> _currentUser = ValueNotifier<EmployeeModel?>(null);
  ValueNotifier<EmployeeModel?> get currentUser => _currentUser;

  String? _currentUserImageUrl;
  String? get currentUserImageUrl => _currentUserImageUrl;

  late final StreamSubscription<bool> _loadingSubscription; 
  late final StreamSubscription<AuthStatus> _authStatusSubscription;

  final AuthRepository _authRepository;
  final AbstractPrefsRepository _prefsRepository;
  final EmployeeRepository _employeeRepository;
  final FormRepository _formRepository;

  late CommandNoArgs logout;
  late CommandWithArgs checkPassword;
  late CommandWithArgs setDarkMode;
  late CommandWithArgs setEmployeeManagementSearchKeyword;

  DashboardViewModel({
    required AuthRepository authRepository, 
    required AbstractPrefsRepository prefsRepository,
    required EmployeeRepository employeeRepository,
    required FormRepository formRepository,
    required ThemeModeNotifier themeNotifier
  })
    : _authRepository = authRepository, 
    _prefsRepository = prefsRepository,
    _employeeRepository = employeeRepository,
    _formRepository = formRepository,
    _themeNotifier = themeNotifier {
    _subscribeToLoadingStatus(); 
    _subscribeToAuthStatus();
    logout = CommandNoArgs<void>(_logout);
    checkPassword = CommandWithArgs<void, String>(_checkPassword);
    setDarkMode = CommandWithArgs<void, ThemeMode>(_setDarkMode);
    setEmployeeManagementSearchKeyword = CommandWithArgs<void, String?>(_setSearchKeyword);

    _getUserImage();
    _subscribeToAnalysisStatus();
  }

  void _subscribeToAnalysisStatus() {
    _formRepository.isAnalysisRunning.addListener(() {
      notifyListeners(); // Optional: only if you need to rebuild things not using ValueListenableBuilder
    });
  }

  @override
  void dispose() {
    _loadingSubscription.cancel(); 
    _authStatusSubscription.cancel();
    super.dispose();
  }

  void _subscribeToLoadingStatus() {
    _loadingSubscription = _authRepository.isLoadingStream.listen((isRepoLoading) {
      if (_isLoading != isRepoLoading) {
        _isLoading = isRepoLoading;
        notifyListeners();
      }
    });
  }

  void _getUserImage() async {
    final currentUserLocal = await _authRepository.getAuthenticatedUserData();

    if (currentUserLocal?.email == _currentUser.value?.email) {
      return;
    }

    if (currentUserLocal != null) {
      final result = await _authRepository.getAuthenticatedUserImage(currentUserLocal);
      if (result case Ok(value: final signedUrl)) {
        _currentUser.value = currentUserLocal.copyWith(photoUrl: signedUrl);
        _currentUserImageUrl = signedUrl;
        notifyListeners();
      } else {
        _currentUserImageUrl = null;
      }
    }
  }

  void _subscribeToAuthStatus() async {
    // 2. Listener for high-level authentication changes (signedIn/signedOut)
    _authStatusSubscription = _authRepository.authStatusStream.listen((status) async {
      if (status == AuthStatus.signedIn) {
        // We need the concrete user object, which the Service/Client provides globally
        EmployeeModel? user = await _authRepository.getAuthenticatedUserData();
        if (user != null) {
          _isAuthenticated = true;
        }
      } else if (status == AuthStatus.signedOut) {
        _isAuthenticated = false;
      }
      notifyListeners();
    });
    
    // Check initial state after setting up the listener
    _checkInitialAuthState();
  }

  void _checkInitialAuthState() async {
    var currentUser = await _authRepository.getAuthenticatedUserData();
    _isAuthenticated = currentUser != null;
    _currentUser.value = currentUser;
    notifyListeners();
  }

  Future<Result<void>> _logout() async {
    final result = _authRepository.logout();
    await _prefsRepository.setKeepLoggedIn(false);
    notifyListeners();

    return result;
  }

  Future<Result<void>> _checkPassword(String password) async {
    final result = await _authRepository.checkPassword(password);

    return result;
  }

  Future<Result<void>> _setDarkMode(ThemeMode themeMode) async {
    try {
      _themeNotifier.setThemeMode(themeMode);
      final result = await _prefsRepository.setThemeMode(themeMode);

      if (!result) {
        return Result.error(CustomMessageException("Failed to set Theme Mode"));
      }
      
      return Result.ok(null);
    } on Error {
      return Result.error(CustomMessageException("Can't set Dark Mode"));
    }
  }

  Future<Result<void>> _setSearchKeyword(String? keyword) async {
    try {
      final result = await _employeeRepository.setSearchKeyword(keyword);

      return result;
    } on Error {
      return Result.error(CustomMessageException("Can't set keyword"));
    }
  }
}