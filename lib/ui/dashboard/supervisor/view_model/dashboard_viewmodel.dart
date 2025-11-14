import 'dart:async';

import 'package:ephor/data/repositories/auth/auth_repository.dart';
import 'package:ephor/data/services/supabase/supabase_service.dart';
import 'package:ephor/domain/enums/auth_status.dart';
import 'package:ephor/utils/command.dart';
import 'package:ephor/utils/results.dart';
import 'package:flutter/foundation.dart';

class DashboardViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  late final StreamSubscription<bool> _loadingSubscription; 
  late final StreamSubscription<AuthStatus> _authStatusSubscription; 

  final AuthRepository _authRepository;
  late CommandNoArgs logout;

  DashboardViewModel({required AuthRepository authRepository})
    : _authRepository = authRepository {
    _subscribeToLoadingStatus(); 
    _subscribeToAuthStatus();
    logout = CommandNoArgs<void>(_logout);
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

  void _subscribeToAuthStatus() {
    // 2. Listener for high-level authentication changes (signedIn/signedOut)
    _authStatusSubscription = _authRepository.authStatusStream.listen((status) {
      if (status == AuthStatus.signedIn) {
        // We need the concrete user object, which the Service/Client provides globally
        final user = SupabaseService.auth.currentUser;
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

  void _checkInitialAuthState() {
    var currentUser = SupabaseService.auth.currentUser;
    _isAuthenticated = currentUser != null;
    notifyListeners();
  }

  Future<Result<void>> _logout() async {
    final result = _authRepository.logout();
    notifyListeners();

    return result;
  }

  // Placeholder for future 'Edit Profile' logic
  void editProfile() {
    // Logic to prepare for profile editing...
    print("Edit profile initiated.");
  }
}