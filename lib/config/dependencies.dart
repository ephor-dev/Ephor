import 'package:ephor/data/repositories/auth/auth_repository.dart';
import 'package:ephor/data/repositories/employee/abstract_employee_repository.dart';
import 'package:ephor/data/repositories/employee/employee_repository.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:ephor/data/services/supabase/supabase_service.dart';

List<SingleChildWidget> get providers {
  return [
    Provider(create: (context) => SupabaseService()),
    Provider<AbstractEmployeeRepository>(
      create: (context) => 
        EmployeeRepository(
          employeeService: context.read<SupabaseService>(), 
        ),
    ),
    ChangeNotifierProvider(
      create: (context) =>
        AuthRepository(
          supabaseService: context.read(),
        ),
    ),
  ];
}