import 'package:flutter/foundation.dart';

@immutable
class PersonnelModel {
  final String id;
  final String lastName;
  final String firstName;
  final String? middleName;
  final EmployeeType employeeType;
  final String? department;
  final List<String> extraTags;
  final DateTime createdAt;

  const PersonnelModel({
    required this.id,
    required this.lastName,
    required this.firstName,
    this.middleName,
    required this.employeeType,
    this.department,
    this.extraTags = const <String>[],
    required this.createdAt,
  });

  String get fullName {
    final String mid = (middleName == null || middleName!.trim().isEmpty) ? '' : ' ${middleName!.trim()}';
    return '${lastName.trim()}, ${firstName.trim()}$mid';
  }

  PersonnelModel copyWith({
    String? id,
    String? lastName,
    String? firstName,
    String? middleName,
    EmployeeType? employeeType,
    String? department,
    List<String>? extraTags,
    DateTime? createdAt,
  }) {
    return PersonnelModel(
      id: id ?? this.id,
      lastName: lastName ?? this.lastName,
      firstName: firstName ?? this.firstName,
      middleName: middleName ?? this.middleName,
      employeeType: employeeType ?? this.employeeType,
      department: department ?? this.department,
      extraTags: extraTags ?? this.extraTags,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory PersonnelModel.fromJson(Map<String, Object?> json) {
    return PersonnelModel(
      id: json['id'] as String,
      lastName: json['lastName'] as String,
      firstName: json['firstName'] as String,
      middleName: json['middleName'] as String?,
      employeeType: EmployeeType.values.byName(json['employeeType'] as String),
      department: json['department'] as String?,
      extraTags: (json['extraTags'] as List<dynamic>? ?? <dynamic>[]).map((dynamic e) => e.toString()).toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'id': id,
      'lastName': lastName,
      'firstName': firstName,
      'middleName': middleName,
      'employeeType': employeeType.name,
      'department': department,
      'extraTags': extraTags,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

enum EmployeeType { personnel, faculty, jobOrder }

