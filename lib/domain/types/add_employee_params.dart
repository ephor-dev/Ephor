import 'package:ephor/domain/enums/employee_role.dart';

typedef AddEmployeeParams = ({
  String lastName,
  String firstName,
  String middleName,
  String? email, // Now conditionally required
  String? password, // Now conditionally required
  EmployeeRole employeeRole, 
  String? department,
  String tags,
  String? photoUrl,
});