import 'dart:math';

import 'package:ephor/domain/enums/employee_role.dart';
import 'package:ephor/domain/models/employee/employee.dart';
import 'package:csv/csv.dart';

String _safeGetString(List<dynamic> row, int index) {
  if (index >= row.length || row[index] == null) {
    return '';
  }

  return row[index].toString().trim();
}

EmployeeRole _parseEmployeeRole(String roleString) {
  return EmployeeRole.values.firstWhere(
    (e) => e.name.toLowerCase() == roleString.toLowerCase(),
    orElse: () => EmployeeRole.personnel,
  );
}

class CsvEmployeeMapper {
  static const int _firstNameIndex = 0;
  static const int _lastNameIndex = 1;
  static const int _emailIndex = 2;
  static const int _roleIndex = 3;
  static const int _departmentIndex = 4;
  static const int _middleNameIndex = 5;
  static const int _extraTagsIndex = 6;
  
  static const int _minRequiredColumns = 5;

  static List<EmployeeModel> mapCsvToEmployees(String rawCsvString) {
    if (rawCsvString.isEmpty) {
      return const [];
    }

    final List<List<dynamic>> rawData = const CsvToListConverter().convert(rawCsvString);

    if (rawData.isEmpty) {
      return const [];
    }
    
    final List<EmployeeModel> employees = [];
    for (int i = 1; i < rawData.length; i++) {
      final row = rawData[i];
      
      if (row.length < _minRequiredColumns) {
        // You might handle this error by creating a special "Invalid" EmployeeModel
        // For simplicity here, we skip malformed rows.
        continue; 
      }

      final firstName = _safeGetString(row, _firstNameIndex);
      final lastName = _safeGetString(row, _lastNameIndex);
      final email = _safeGetString(row, _emailIndex);
      final roleString = _safeGetString(row, _roleIndex);
      final department = _safeGetString(row, _departmentIndex);
      final middleName = _safeGetString(row, _middleNameIndex);
      final tagsString = _safeGetString(row, _extraTagsIndex);

      // --- Validation (Simplified) ---
      // final isValid = firstName.isNotEmpty && email.isNotEmpty && employeeCode.isNotEmpty;
      
      // If data is invalid, you would typically create a special model 
      // with validation status for the ViewModel to display. 
      // For now, we create the full model regardless.

    String rolePrefix;
    switch (EmployeeRole.values.byName(roleString)) {
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

      employees.add(
        EmployeeModel(
          employeeCode: employeeCode,
          email: email,
          role: _parseEmployeeRole(roleString),
          firstName: firstName,
          lastName: lastName,
          department: department,
          middleName: middleName.isNotEmpty ? middleName : null,
          extraTags: tagsString.isNotEmpty ? tagsString.split(',').map((e) => e.trim()).toList() : const [],
        )
      );
    }

    return employees;
  }
}