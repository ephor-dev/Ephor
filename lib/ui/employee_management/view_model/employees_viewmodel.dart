import 'dart:async';

import 'package:ephor/data/repositories/auth/abstract_auth_repository.dart';
import 'package:ephor/data/repositories/employee/employee_repository.dart';
import 'package:ephor/domain/enums/employee_role.dart';
import 'package:ephor/domain/models/employee/employee.dart';
import 'package:ephor/utils/command.dart';
import 'package:ephor/utils/custom_message_exception.dart';
import 'package:ephor/utils/results.dart';
import 'package:flutter/foundation.dart';
import 'package:fuzzy/fuzzy.dart';

class EmployeeListViewModel extends ChangeNotifier {
  final EmployeeRepository _employeeRepository;
  final AbstractAuthRepository _authRepository;

  EmployeeModel? _currentUser;
  EmployeeModel? get currentUser => _currentUser;

  StreamSubscription? _authSubscription;
  
  List<EmployeeModel> _employees = [];
  final bool _isLoading = false;

  late CommandWithArgs deleteEmployee;
  late CommandWithArgs deleteBatchEmployees;
  late CommandNoArgs loadEmployees;

  EmployeeListViewModel({
    required EmployeeRepository employeeRepository,
    required AbstractAuthRepository authRepository
  }) : _employeeRepository = employeeRepository,
      _authRepository = authRepository {
    _loadEmployees();

    loadEmployees = CommandNoArgs<void>(_loadEmployees);
    deleteEmployee = CommandWithArgs<void, EmployeeModel>(_deleteEmployee);
    deleteBatchEmployees = CommandWithArgs<void, List<EmployeeModel>>(_deleteBatchEmployees);

    _getCurrentUser();
    _listenToSearchKeywords();
  }

  // Exposed State
  List<EmployeeModel> get employees => _employees;
  bool get isLoading => _isLoading;

  String? _searchKeyword;
  String? get searchKeyword => _searchKeyword;

  void _listenToSearchKeywords() {
   _employeeRepository.searchKeyword.addListener(() {
      _searchKeyword = _employeeRepository.searchKeyword.value;
      notifyListeners();
   });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  void _getCurrentUser() {
    final currentUser = _authRepository.currentUser;
    if (currentUser == null) {
      _currentUser = null;
    } else {
      _currentUser = currentUser;
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

  Future<Result<String>> _deleteBatchEmployees(List<EmployeeModel> employeeList) async {
    int success = 0;
    for (EmployeeModel employee in employeeList) {
      final result = await _deleteEmployee(employee);

      if (result case Ok()) {
        success++;
      }
    }

    if (success != employeeList.length) {
      return Result.error(CustomMessageException('Only $success of ${employeeList.length} Employees deleted.'));
    }

    return Result.ok('Batch Employee Deletion successfully finished!');
  }

  List<EmployeeModel> searchEmployees(List<EmployeeModel> allEmployees, String? query) {
    if (query == null || query.isEmpty) {
      return allEmployees;
    }

    final fuse = Fuzzy<EmployeeModel>(
      allEmployees,
      options: FuzzyOptions(
        keys: [
          WeightedKey(
            name: 'fullName',
            getter: (employee) => '${employee.firstName} ${employee.lastName} ${employee.middleName ?? ''}',
            weight: 1.0, 
          ),
          WeightedKey(
            name: 'email',
            getter: (employee) => employee.email,
            weight: 0.8,
          ),
          WeightedKey(
            name: 'tags',
            getter: (employee) => employee.extraTags.join(' '), 
            weight: 0.8,
          ),
          WeightedKey(
            name: 'role',
            getter: (employee) => employee.role.displayName, 
            weight: 0.5,
          ),
          WeightedKey(
            name: 'department',
            getter: (employee) => employee.department,
            weight: 0.5,
          ),
        ],
        threshold: 0.4, 
      ),
    );

    final result = fuse.search(query);
    return result.map((r) => r.item).toList();
  }
}