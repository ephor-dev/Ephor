import 'package:flutter/material.dart';
import '../../data/models/app_user_model.dart';
import '../../data/repositories/auth_repository.dart';

class DashboardViewModel extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  AppUser? _user;
  AppUser? get user => _user;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  DashboardViewModel() {
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    try {
      _isLoading = true;
      notifyListeners();
      _user = await _authRepository.getAppUserProfile();
    } catch (e) {
      _errorMessage = "Could not fetch user profile.";
      print(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
  }
}