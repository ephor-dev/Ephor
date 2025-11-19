import 'package:ephor/data/repositories/shared_prefs/abstract_prefs_repository.dart';
import 'package:ephor/data/services/shared_prefs/prefs_service.dart';

// Keys used by the application (Domain Constants)
abstract class PrefsKeys {
  static const String keepLoggedIn = 'keep_logged_in';
  static const String darkMode = 'setting_dark_mode';
}

class PrefsRepository implements AbstractPrefsRepository {
  final PrefsService _prefsService;

  PrefsRepository({required PrefsService prefsService})
    : _prefsService = prefsService;

  // --- Session Data (Example: String) ---

  @override
  Future<bool> getKeepLoggedIn() async {
    return _prefsService.getBool(PrefsKeys.keepLoggedIn);
  }

  @override
  Future<bool> setKeepLoggedIn(bool state) async {
    return await _prefsService.setBool(PrefsKeys.keepLoggedIn, state);
  }

  // --- Settings Data (Example: Boolean) ---

  @override
  Future<bool> getIsDarkMode() async {
    return _prefsService.getBool(PrefsKeys.darkMode);
  }

  @override
  Future<bool> setIsDarkMode(bool isDarkMode) async {
    return await _prefsService.setBool(PrefsKeys.darkMode, isDarkMode);
  }

  // --- Clear/Logout Action ---

  @override
  Future<void> clearSessionData() async {
    // Clear only session-related keys, leaving settings untouched (optional)
    await _prefsService.remove(PrefsKeys.keepLoggedIn);
    // You can choose to clear all via _prefsService.clearAll() if needed.
  }
}