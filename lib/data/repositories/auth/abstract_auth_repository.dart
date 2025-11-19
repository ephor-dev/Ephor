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
    required String userRole,
    required bool rememberMe
  });

  /// Perform logout
  Future<Result<void>> logout();
}