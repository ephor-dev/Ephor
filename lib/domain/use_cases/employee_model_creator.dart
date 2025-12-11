import 'dart:math';

import 'package:ephor/domain/enums/employee_role.dart';
import 'package:ephor/domain/models/employee/employee.dart';
import 'package:ephor/domain/types/add_employee_params.dart';

EmployeeModel createEmployeeModel(AddEmployeeParams params, String? userId, String? photoUrl) {
    final List<String> tagList = params.tags
        .split(',')
        .map((String e) => e.trim())
        .where((String e) => e.isNotEmpty)
        .toList(growable: false);

    String rolePrefix;
    switch (params.employeeRole) {
      case EmployeeRole.supervisor:
        rolePrefix = 's-';
        break;
      case EmployeeRole.humanResource:
        rolePrefix = 'hr-';
        break;
      case EmployeeRole.personnel:
        rolePrefix = 'p-';
        break;
      case EmployeeRole.faculty:
        rolePrefix = 'f-';
        break;
      case EmployeeRole.jobOrder:
        rolePrefix = 'jo-';
        break;
    }

    final now = DateTime.now();
    final randomPart = Random().nextInt(90000) + 10000;
    final timePart = now.second.toString().padLeft(2, '0');

    // Final code format: ROLE-#####SS (e.g., hr-1234560)
    final String employeeCode = '$rolePrefix$randomPart$timePart';
    // Use the Supabase Auth ID if available, otherwise use null
    return EmployeeModel(
      id: userId, 
      employeeCode: employeeCode, 
      email: params.email ?? 'N/A', // Set email to N/A if not provided
      role: params.employeeRole,
      
      lastName: params.lastName,
      firstName: params.firstName,
      middleName: params.middleName.isEmpty ? null : params.middleName,
      department: params.department ?? 'N/A', 
      extraTags: tagList,
      photoUrl: photoUrl,
      catnaAssessed: false,
      impactAssessed: true
    );
  }