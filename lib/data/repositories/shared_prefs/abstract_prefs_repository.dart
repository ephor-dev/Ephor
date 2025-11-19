abstract interface class AbstractPrefsRepository {
  Future<bool> getKeepLoggedIn();
  Future<bool> setKeepLoggedIn(bool state);
  Future<bool> getIsDarkMode();
  Future<bool> setIsDarkMode(bool isDarkMode);
  Future<void> clearSessionData();
}