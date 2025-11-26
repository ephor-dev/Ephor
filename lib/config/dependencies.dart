import 'package:ephor/data/repositories/auth/auth_repository.dart';
import 'package:ephor/data/repositories/employee/abstract_employee_repository.dart';
import 'package:ephor/data/repositories/employee/employee_repository.dart';
import 'package:ephor/data/repositories/form/abstract_form_repository.dart';
import 'package:ephor/data/repositories/form/mock_form_repository.dart';
import 'package:ephor/data/repositories/shared_prefs/abstract_prefs_repository.dart';
import 'package:ephor/data/repositories/shared_prefs/prefs_repository.dart';
import 'package:ephor/data/services/shared_prefs/prefs_service.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:ephor/data/services/supabase/supabase_service.dart';

List<SingleChildWidget> get providers {
  return [
    Provider(create: (context) => PrefsService()),
    Provider(create: (context) => SupabaseService()),
    Provider<AbstractEmployeeRepository>(
      create: (context) => 
        EmployeeRepository(
          employeeService: context.read<SupabaseService>(), 
        ),
    ),
    // Form Repository - Using Mock for now, swap to Supabase later
    Provider<IFormRepository>(
      create: (context) => MockFormRepository(),
    ),
    ChangeNotifierProvider(
      create: (context) =>
        AuthRepository(
          supabaseService: context.read(),
        ),
    ),
    Provider<AbstractPrefsRepository>(
      create: (context) =>
        PrefsRepository(
          prefsService: context.read()
        )
    )
  ];
}