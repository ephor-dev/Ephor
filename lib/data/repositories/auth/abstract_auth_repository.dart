import 'package:ephor/domain/models/employee/employee.dart';
import 'package:flutter/foundation.dart';
import 'package:ephor/utils/results.dart';

abstract class AbstractAuthRepository extends ChangeNotifier {
  /// Returns true when the user is logged in
  /// Returns [Future] because it will load a stored auth state the first time.
  Future<bool> get isAuthenticated;

  EmployeeModel? get currentUser => null;

  /// Perform login
  Future<Result<void>> login({
    required String employeeCode,
    required String password,
    required String userRole
  });

  /// Perform logout
  Future<Result<void>> logout();

  Future<dynamic> signUpNewUser(String email, String password) async {}

  Future<Result<String?>> getAuthenticatedUserImage(EmployeeModel user);
  Future<Result<void>> changePassword(String password);
  Future<Result<void>> changeEmail(String email);
  Future<Result<void>> sendPasswordResetEmail(String email);
  Future<Result<void>> checkPassword(String password);
}