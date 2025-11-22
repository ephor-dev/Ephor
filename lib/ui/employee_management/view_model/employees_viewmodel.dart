import 'dart:async';

import 'package:ephor/data/repositories/auth/abstract_auth_repository.dart';
import 'package:ephor/data/repositories/employee/abstract_employee_repository.dart';
import 'package:ephor/domain/enums/employee_role.dart';
import 'package:ephor/domain/models/employee/employee.dart';
import 'package:ephor/utils/command.dart';
import 'package:ephor/utils/results.dart';
import 'package:flutter/foundation.dart';

class EmployeeListViewModel extends ChangeNotifier {
  final AbstractEmployeeRepository _employeeRepository;
  final AbstractAuthRepository _authRepository;

  EmployeeRole? _currentUserRole;
  EmployeeRole? get currentUserRole => _currentUserRole;

  StreamSubscription? _authSubscription;
  
  List<EmployeeModel> _employees = [];
  final bool _isLoading = false;

  late CommandWithArgs deleteEmployee;
  late CommandNoArgs loadEmployees;

  EmployeeListViewModel({
    required AbstractEmployeeRepository employeeRepository,
    required AbstractAuthRepository authRepository
  }) : _employeeRepository = employeeRepository,
      _authRepository = authRepository {
    _loadEmployees();

    loadEmployees = CommandNoArgs<void>(_loadEmployees);
    deleteEmployee = CommandWithArgs<void, EmployeeModel>(_deleteEmployee);

    _getCurrentUser();
  }

  // Exposed State
  List<EmployeeModel> get employees => _employees;
  bool get isLoading => _isLoading;

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  void _getCurrentUser() {
    final currentUser = _authRepository.currentUser;
    if (currentUser == null) {
      _currentUserRole = null;
    } else if (currentUser.role == EmployeeRole.humanResource) {
      _currentUserRole = EmployeeRole.humanResource;
    } else {
      _currentUserRole = currentUser.role;
    }
    notifyListeners();
  }

  Future<Result<void>> _loadEmployees() async {
    final result = await _employeeRepository.fetchAllEmployees();

    if (result case Ok(value: final list)) {
      _employees = list;
      notifyListeners();
      return const Result.ok(null);
    } else {
      _employees = [];
      return result;
    }
  }

  Future<Result<void>> _deleteEmployee(EmployeeModel employee) async {
    // 1. Call the Repository
    final result = await _employeeRepository.removeEmployee(employee.userId);

    if (employee.photoUrl != null) {
      final deleteResult = await _employeeRepository.deleteOldPhoto(employee.photoUrl!);

      if (deleteResult case Error()) {
        return deleteResult;
      }
    }
    
    // 2. Update local state ONLY if successful
    if (result case Ok()) {
      _employees.removeWhere((e) => e.userId == employee.userId);
      notifyListeners();
      return const Result.ok(null);
    } else {
      // Return the error from the repository
      return result; 
    }
  }
}