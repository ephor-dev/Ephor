import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  static late SharedPreferences _instance;

  /// Must be called once before using the service to load preferences.
  static Future<void> initialize() async {
    _instance = await SharedPreferences.getInstance();
  }

  static SharedPreferences getInstance() {
    return _instance;
  }

  // --- Low-Level CRUD Operations ---

  /// Reads a single key synchronously.
  dynamic get(String key) {
    return _instance.get(key);
  }

  /// Writes String data.
  Future<bool> setString(String key, String value) {
    return _instance.setString(key, value);
  }

  /// Writes Boolean data.
  Future<bool> setBool(String key, bool value) {
    return _instance.setBool(key, value);
  }

  /// Reads String data, defaulting to null.
  String? getString(String key) {
    return _instance.getString(key);
  }

  /// Reads Boolean data, defaulting to false.
  bool getBool(String key) {
    return _instance.getBool(key) ?? false;
  }

  /// Clears a specific key.
  Future<bool> remove(String key) {
    return _instance.remove(key);
  }

  /// Clears ALL stored keys.
  Future<bool> clearAll() {
    return _instance.clear();
  }
}