// domain/models/employee/employee.dart

import 'package:flutter/foundation.dart';

enum EmployeeType {
  personnel,
  faculty,
  jobOrder,
}

@immutable
class EmployeeModel {
  final String id;
  final String lastName;
  final String firstName;
  final String? middleName;
  final EmployeeType employeeType;
  final String? department;
  final List<String> extraTags;
  final String? photoUrl;
  final DateTime createdAt;

  const EmployeeModel({
    required this.id,
    required this.lastName,
    required this.firstName,
    this.middleName,
    required this.employeeType,
    this.department,
    this.extraTags = const [],
    this.photoUrl,
    required this.createdAt,
  });

  String get fullName {
    if (middleName != null && middleName!.isNotEmpty) {
      return '$lastName, $firstName $middleName.';
    }
    return '$lastName, $firstName';
  }

  EmployeeModel copyWith({
    String? id,
    String? lastName,
    String? firstName,
    String? middleName,
    EmployeeType? employeeType,
    String? department,
    List<String>? extraTags,
    String? photoUrl,
    DateTime? createdAt,
  }) {
    return EmployeeModel(
      id: id ?? this.id,
      lastName: lastName ?? this.lastName,
      firstName: firstName ?? this.firstName,
      middleName: middleName ?? this.middleName,
      employeeType: employeeType ?? this.employeeType,
      department: department ?? this.department,
      extraTags: extraTags ?? this.extraTags,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'last_name': lastName,
      'first_name': firstName,
      'middle_name': middleName,
      'employee_type': employeeType.name,
      'department': department,
      'extra_tags': extraTags,
      'photo_url': photoUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory EmployeeModel.fromJson(Map<String, dynamic> map) {
    return EmployeeModel(
      id: map['id'] as String,
      lastName: map['last_name'] as String,
      firstName: map['first_name'] as String,
      middleName: map['middle_name'] as String?,
      employeeType: EmployeeType.values.firstWhere((e) => e.name == map['employee_type']),
      department: map['department'] as String?,
      extraTags: List<String>.from((map['extra_tags'] as List<dynamic>? ?? []).map((e) => e.toString())),
      photoUrl: map['photo_url'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}