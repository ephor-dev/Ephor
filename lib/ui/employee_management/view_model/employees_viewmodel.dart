import 'package:ephor/data/repositories/employee/abstract_employee_repository.dart';
import 'package:ephor/domain/models/employee/employee.dart';
import 'package:ephor/utils/command.dart';
import 'package:ephor/utils/results.dart';
import 'package:flutter/foundation.dart';

class EmployeeListViewModel extends ChangeNotifier {
  final AbstractEmployeeRepository _repository;
  
  List<EmployeeModel> _employees = [];
  bool _isLoading = false;

  late CommandWithArgs deleteEmployee;
  late CommandNoArgs loadEmployees;

  EmployeeListViewModel({required AbstractEmployeeRepository repository}) 
    : _repository = repository {
    _loadEmployees();

    loadEmployees = CommandNoArgs<void>(_loadEmployees);
    deleteEmployee = CommandWithArgs<void, String>(_deleteEmployee);
  }

  // Exposed State
  List<EmployeeModel> get employees => _employees;
  bool get isLoading => _isLoading;


  Future<Result<void>> _loadEmployees() async {
    final result = await _repository.fetchAllEmployees();

    if (result case Ok(value: final list)) {
      _employees = list;
      notifyListeners();
      return const Result.ok(null);
    } else {
      _employees = [];
      return result;
    }
  }

  Future<Result<void>> _deleteEmployee(String employeeId) async {
    // 1. Call the Repository
    final result = await _repository.removeEmployee(employeeId);
    
    // 2. Update local state ONLY if successful
    if (result case Ok()) {
      _employees.removeWhere((e) => e.id == employeeId);
      notifyListeners();
      return const Result.ok(null);
    } else {
      // Return the error from the repository
      return result; 
    }
  }
}