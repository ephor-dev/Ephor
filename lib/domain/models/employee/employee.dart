// domain/models/employee/employee.dart

import 'package:ephor/domain/enums/employee_role.dart';
import 'package:flutter/foundation.dart';

@immutable
class EmployeeModel {
  // Field remains non-nullable, but initialized with a placeholder if not provided
  final String userId; 
  final String employeeCode; 
  final String email;
  final EmployeeRole role; 
  final String department; 
  
  final String firstName; 
  final String lastName; 
  final String? middleName;
  final List<String> extraTags; 
  final String? photoUrl;
  final bool catnaAssessed;
  final bool impactAssessed;

  const EmployeeModel({
    String? id, // Allows null/omission during creation
    required this.employeeCode,
    required this.email,
    required this.role,
    required this.firstName,
    required this.lastName,
    required this.department, 
    this.middleName,
    this.extraTags = const [],
    this.photoUrl,
    required this.catnaAssessed,
    required this.impactAssessed
  }) : userId = id ?? ''; // Use empty string placeholder if null

  String get fullName {
    final middle = (middleName != null && middleName!.isNotEmpty) ? '$middleName.' : '';
    return '$lastName, $firstName $middle'.trim();
  }

  EmployeeModel copyWith({
    String? id,
    String? employeeCode,
    String? email,
    EmployeeRole? role,
    String? firstName,
    String? lastName,
    String? department,
    String? middleName,
    List<String>? extraTags,
    String? photoUrl,
    bool? catnaAssessed,
    bool? impactAssessed
  }) {
    return EmployeeModel(
      id: id ?? userId,
      employeeCode: employeeCode ?? this.employeeCode,
      email: email ?? this.email,
      role: role ?? this.role,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      department: department ?? this.department,
      middleName: middleName ?? this.middleName,
      extraTags: extraTags ?? this.extraTags,
      photoUrl: photoUrl ?? this.photoUrl,
      catnaAssessed: catnaAssessed ?? false,
      impactAssessed: impactAssessed ?? true
    );
  }

  // CRITICAL FIX: Only include 'id' if it's set and not the placeholder.
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'employee_code': employeeCode,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'tags': extraTags.join(','), 
      'department': department,
      'role': role.name, 
      'photo_url': photoUrl,
      'catna_assessed': catnaAssessed,
      'impact_assessed': impactAssessed
    };
    if (userId.isNotEmpty) {
      map['id'] = userId;
    }
    return map;
  }

  factory EmployeeModel.fromJson(Map<String, dynamic> map) {
    EmployeeRole parseRole(String roleName) {
      return EmployeeRole.values.firstWhere(
        (e) => e.name.toLowerCase() == roleName.toLowerCase(),
        orElse: () => EmployeeRole.personnel,
      );
    }
    
    List<String> parseTags(dynamic tags) {
      if (tags is String && tags.isNotEmpty) {
        return tags.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      }
      return const [];
    }

    return EmployeeModel(
      id: map['id'] as String,
      employeeCode: map['employee_code'] as String,
      email: map['email'] as String,
      role: parseRole(map['role'] as String),
      firstName: map['first_name'] as String,
      lastName: map['last_name'] as String,
      department: map['department'] as String,
      middleName: map['middle_name'] as String?, 
      extraTags: parseTags(map['tags']), 
      photoUrl: map['photo_url'] as String?,
      catnaAssessed: map['catna_assessed'] as bool,
      impactAssessed: map['impact_assessed'] as bool
    );
  }
}