import 'package:ephor/data/repositories/auth/auth_repository.dart';
import 'package:ephor/data/repositories/employee/abstract_employee_repository.dart';
import 'package:ephor/data/repositories/employee/employee_repository.dart';
import 'package:ephor/data/services/supabase/employee_supabase_service.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:ephor/data/services/supabase/supabase_service.dart';

List<SingleChildWidget> get providers {
  return [
    Provider(create: (context) => SupabaseService()),
    Provider(create: (context) => EmployeeSupabaseService()),
    Provider<AbstractEmployeeRepository>(
      create: (context) => EmployeeRepository(
        employeeService: context.read<EmployeeSupabaseService>(), 
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