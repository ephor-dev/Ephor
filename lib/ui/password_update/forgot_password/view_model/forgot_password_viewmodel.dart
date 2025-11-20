// presentation/viewmodels/login_view_model.dart

import 'dart:async';
import 'package:ephor/utils/custom_message_exception.dart';
import 'package:ephor/utils/results.dart';
import 'package:flutter/foundation.dart';
import 'package:ephor/data/repositories/auth/auth_repository.dart';
import 'package:ephor/utils/command.dart';

class ForgotPasswordViewModel extends ChangeNotifier {
  
  final AuthRepository _authRepository;
  
  // Subscriptions to the Repository streams
  late final StreamSubscription<bool> _loadingSubscription;

  // --- State Properties ---
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  late CommandWithArgs sendLinkCommand;

  ForgotPasswordViewModel({required AuthRepository authRepository})
    : _authRepository = authRepository {
    // 1. Initialize and subscribe to ALL Repository streams
    _subscribeToLoadingStatus();
    
    // Command setup
    sendLinkCommand = CommandWithArgs<void, String>(_sendLink);
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

  @override
  void dispose() {
    _loadingSubscription.cancel();
    super.dispose();
  }

  // --- Command Implementation (Clean Delegation) ---
  Future<Result<void>> _sendLink(String employeeCode) async {
    final result = await _authRepository.sendPasswordResetEmail(employeeCode);

    if (result case Ok()) {
      notifyListeners();
      return Result.ok(null);
    } else if (result case Error(:final error)) {
      notifyListeners();
      return Result.error(CustomMessageException(error.toString()));
    }

    return Result.error(CustomMessageException("Failed to send link."));
  }
}