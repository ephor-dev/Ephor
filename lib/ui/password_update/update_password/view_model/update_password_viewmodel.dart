import 'dart:async';
import 'package:ephor/utils/custom_message_exception.dart';
import 'package:ephor/utils/results.dart';
import 'package:flutter/foundation.dart';
import 'package:ephor/data/repositories/auth/auth_repository.dart';
import 'package:ephor/utils/command.dart';

class UpdatePasswordViewModel extends ChangeNotifier {
  
  final AuthRepository _authRepository;
  late final StreamSubscription<bool> _loadingSubscription;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  late CommandWithArgs<void, String> updateCommand;

  UpdatePasswordViewModel({required AuthRepository authRepository})
    : _authRepository = authRepository {
    
    _subscribeToLoadingStatus();
    updateCommand = CommandWithArgs<void, String>(_updatePassword);
  }

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

  Future<Result<void>> _updatePassword(String newPassword) async {
    final result = await _authRepository.changePassword(newPassword);

    if (result case Ok()) {
      notifyListeners();
      return Result.ok(null);
    } else if (result case Error(:final error)) {
      notifyListeners();
      return Result.error(CustomMessageException(error.toString()));
    }
    return Result.error(CustomMessageException("Failed to update password."));
  }
}