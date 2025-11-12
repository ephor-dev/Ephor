import 'package:flutter/foundation.dart';

class UserProfileViewModel extends ChangeNotifier {
  // ----------------------------------------------------
  // 1. STATE/DATA (Placeholder for data fetched from DB)
  // ----------------------------------------------------
  
  // Use private variables for data storage
  String _currentUserName = "Emmanuel John";
  String _currentUserEmail = "ej.masarap@ephor.com";
  bool _isLoggedIn = true; // State to track login status

  // Public getters to expose data to the UI
  String get currentUserName => _currentUserName;
  String get currentUserEmail => _currentUserEmail;
  bool get isLoggedIn => _isLoggedIn;

  // ----------------------------------------------------
  // 2. LOGIC (Logout Implementation)
  // ----------------------------------------------------

  void logout() {
    // In a real app, this is where you would:
    // 1. Clear authentication tokens (e.g., SharedPreferences, secure storage).
    // 2. Perform any necessary backend calls to invalidate the session.
    
    // Placeholder implementation:
    _isLoggedIn = false;
    _currentUserName = "Guest";
    _currentUserEmail = "guest@example.com";
    
    // IMPORTANT: Call notifyListeners() to tell all listening widgets (your UI)
    // that the data has changed, forcing them to rebuild.
    notifyListeners();
    print("User logged out successfully."); 
  }

  // Placeholder for future 'Edit Profile' logic
  void editProfile() {
    // Logic to prepare for profile editing...
    print("Edit profile initiated.");
  }
}