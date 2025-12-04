import 'package:ephor/data/repositories/shared_prefs/abstract_prefs_repository.dart';
import 'package:ephor/data/services/shared_prefs/prefs_service.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

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
  Future<ThemeMode> getThemeMode() async {
    final themeString = _prefsService.getString(PrefsKeys.darkMode);
    ThemeMode? themeMode = ThemeMode.values.firstWhereOrNull((e) => e.name == themeString);
    
    if (themeMode == null) {
      return ThemeMode.system;
    }

    return themeMode;
  }

  @override
  Future<bool> setThemeMode(ThemeMode themeMode) async {
    return await _prefsService.setString(PrefsKeys.darkMode, themeMode.name);
  }

  // --- Clear/Logout Action ---

  @override
  Future<void> clearSessionData() async {
    // Clear only session-related keys, leaving settings untouched (optional)
    await _prefsService.remove(PrefsKeys.keepLoggedIn);
    // You can choose to clear all via _prefsService.clearAll() if needed.
  }
}