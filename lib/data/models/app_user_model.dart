import 'package:flutter/foundation.dart';

@immutable
class AppUser {
  final String id;
  final String email;
  final String name;
  final String employeeCode;

  const AppUser({
    required this.id,
    required this.email,
    required this.name,
    required this.employeeCode,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      employeeCode: json['employee_code'] as String,
    );
  }
}