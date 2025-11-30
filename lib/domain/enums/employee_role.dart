enum EmployeeRole {
  humanResource,
  supervisor,
  personnel,
  faculty,
  jobOrder,
}

extension EmployeeRoleExtension on EmployeeRole {
  String get displayName {
    switch (this) {
      case EmployeeRole.humanResource:
        return 'Human Resource';
      case EmployeeRole.personnel:
        return 'University Personnel';
      case EmployeeRole.supervisor:
        return 'Supervisor';
      case EmployeeRole.faculty:
        return 'Faculty Member';
      case EmployeeRole.jobOrder:
        return 'Job-Order Worker';
    }
  }
}