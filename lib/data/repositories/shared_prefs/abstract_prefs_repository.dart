import 'package:flutter/material.dart';

abstract interface class AbstractPrefsRepository {
  Future<bool> getKeepLoggedIn();
  Future<bool> setKeepLoggedIn(bool state);
  Future<ThemeMode> getThemeMode();
  Future<bool> setThemeMode(ThemeMode mode);
  Future<void> clearSessionData();
}