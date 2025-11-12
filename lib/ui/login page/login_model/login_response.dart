import 'package:supabase_flutter/supabase_flutter.dart';
import 'employee_model.dart';


/// Model representing login response
class LoginResponse {
  final bool success;
  final String? errorMessage;
  final User? user;
  final Session? session;
  final EmployeeModel? employeeData;

  const LoginResponse({
    required this.success,
    this.errorMessage,
    this.user,
    this.session,
    this.employeeData,
  });

  /// Create successful login response
  factory LoginResponse.success({
    required User user,
    required Session session,
    EmployeeModel? employeeData,
  }) {
    return LoginResponse(
      success: true,
      user: user,
      session: session,
      employeeData: employeeData,
    );
  }

  /// Create failed login response
  factory LoginResponse.failure({
    required String errorMessage,
  }) {
    return LoginResponse(
      success: false,
      errorMessage: errorMessage,
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'error_message': errorMessage,
      'user_id': user?.id,
      'employee_data': employeeData?.toJson(),
    };
  }

  /// Check if user is authenticated
  bool get isAuthenticated => success && user != null && session != null;

  @override
  String toString() {
    return 'LoginResponse(success: $success, userId: ${user?.id}, error: $errorMessage)';
  }
}

