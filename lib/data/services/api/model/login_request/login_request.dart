import 'package:ephor/data/services/api/model/user_role/user_role.dart';

/// Model representing login request credentials
class LoginRequest {
  final String employeeCode;
  final String password;
  final UserRole? userRole;
  final bool rememberMe;

  const LoginRequest({
    required this.employeeCode,
    required this.password,
    this.userRole,
    this.rememberMe = false,
  });

  /// Create LoginRequest from email instead of employee code
  factory LoginRequest.withEmail({
    required String email,
    required String password,
    bool rememberMe = false,
  }) {
    return LoginRequest(
      employeeCode: email,
      password: password,
      rememberMe: rememberMe,
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'employee_code': employeeCode,
      'password': password,
      'user_role': userRole?.value,
      'remember_me': rememberMe,
    };
  }

  /// Create from JSON map
  factory LoginRequest.fromJson(Map<String, dynamic> json) {
    return LoginRequest(
      employeeCode: json['employee_code'] as String? ?? json['email'] as String? ?? '',
      password: json['password'] as String? ?? '',
      userRole: UserRole.fromString(json['user_role'] as String?),
      rememberMe: json['remember_me'] as bool? ?? false,
    );
  }

  @override
  String toString() {
    return 'LoginRequest(employeeCode: $employeeCode, userRole: $userRole, rememberMe: $rememberMe)';
  }
}
