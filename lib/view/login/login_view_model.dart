import 'package:flutter/material.dart';
import '../../data/repositories/auth_repository.dart';

enum ViewState { idle, loading, error }

class LoginViewModel extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  ViewState _state = ViewState.idle;
  ViewState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void _setState(ViewState viewState) {
    _state = viewState;
    notifyListeners();
  }

  Future<void> login(String employeeCode, String password) async {
    if (employeeCode.isEmpty || password.isEmpty) {
      _errorMessage = 'Employee code and password cannot be empty.';
      _setState(ViewState.error);
      return;
    }

    _setState(ViewState.loading);
    _errorMessage = null;

    try {
      await _authRepository.loginWithEmployeeCode(employeeCode, password);
      _setState(ViewState.idle);
    } catch (e) {
      _errorMessage = e.toString();
      _setState(ViewState.error);
    }
  }
}