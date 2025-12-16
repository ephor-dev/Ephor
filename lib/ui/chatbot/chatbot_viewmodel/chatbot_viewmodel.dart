import 'package:ephor/utils/results.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ephor/data/repositories/auth/auth_repository.dart';// NEW IMPORT

/// ViewModel for handling login logic. PURELY handles presentation state.
class ChatbotViewModel extends ChangeNotifier {
  String? _geminiApiKey;
  final AuthRepository _authRepository;

  String? get geminiApiKey => _geminiApiKey;

  ChatbotViewModel({
    required AuthRepository authRepository,
  })
    : _authRepository = authRepository {
    getGeminiKey();
  }

  void getGeminiKey() async {
    final result = await _authRepository.getGeminiKey();
    switch (result) {
      case Ok():
        _geminiApiKey = result.value;
        break;
      case Error():
        print("ERRORS!!!");
        break;
    }
  }
}