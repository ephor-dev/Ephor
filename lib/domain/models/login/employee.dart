/// Model representing employee data from the database
class EmployeeModel {
  final String id;
  final String employeeCode;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? role;
  final DateTime? lastLogin;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const EmployeeModel({
    required this.id,
    required this.employeeCode,
    required this.email,
    this.firstName,
    this.lastName,
    this.role,
    this.lastLogin,
    this.createdAt,
    this.updatedAt,
  });

  /// Get full name
  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else if (firstName != null) {
      return firstName!;
    } else if (lastName != null) {
      return lastName!;
    }
    return email;
  }

  /// Get display name (prefers full name, falls back to email)
  String get displayName => fullName != email ? fullName : email;

  /// Create from JSON map (from Supabase database)
  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json['id'] as String? ?? json['user_id'] as String? ?? '',
      employeeCode: json['employee_code'] as String? ?? '',
      email: json['email'] as String? ?? '',
      firstName: json['first_name'] as String? ?? json['firstName'] as String?,
      lastName: json['last_name'] as String? ?? json['lastName'] as String?,
      role: json['role'] as String?,
      lastLogin: json['last_login'] != null
          ? DateTime.parse(json['last_login'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_code': employeeCode,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'role': role,
      'last_login': lastLogin?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  EmployeeModel copyWith({
    String? id,
    String? employeeCode,
    String? email,
    String? firstName,
    String? lastName,
    String? role,
    DateTime? lastLogin,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EmployeeModel(
      id: id ?? this.id,
      employeeCode: employeeCode ?? this.employeeCode,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role ?? this.role,
      lastLogin: lastLogin ?? this.lastLogin,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'EmployeeModel(id: $id, employeeCode: $employeeCode, email: $email, name: $fullName, role: $role)';
  }
}
