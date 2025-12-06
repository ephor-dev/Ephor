import 'package:ephor/data/repositories/auth/auth_repository.dart';
import 'package:ephor/data/repositories/catna/catna_repository.dart';
import 'package:ephor/data/repositories/employee/abstract_employee_repository.dart';
import 'package:ephor/data/repositories/employee/employee_repository.dart';
import 'package:ephor/data/repositories/form/abstract_form_repository.dart';
import 'package:ephor/data/repositories/form/mock_form_repository.dart';
import 'package:ephor/data/repositories/shared_prefs/abstract_prefs_repository.dart';
import 'package:ephor/data/repositories/shared_prefs/prefs_repository.dart';
import 'package:ephor/data/services/shared_prefs/prefs_service.dart';
import 'package:ephor/ui/core/themes/theme_mode_notifier.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:ephor/data/services/supabase/supabase_service.dart';

List<SingleChildWidget> get providers {
  return [
    Provider(create: (context) => PrefsService()),
    Provider(create: (context) => SupabaseService()),
    ChangeNotifierProvider<ThemeModeNotifier>(
      create: (_) => ThemeModeNotifier(),
    ),
    Provider<AbstractEmployeeRepository>(
      create: (context) => 
        EmployeeRepository(
          employeeService: context.read<SupabaseService>(), 
        ),
    ),
    ChangeNotifierProvider<CatnaRepository>(
      create: (context) => 
        CatnaRepository(
          supabaseService: context.read()
        )
    ),
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
    ),
    ChangeNotifierProvider<ThemeModeNotifier>(
      create: (context) =>
        ThemeModeNotifier()
    )
  ];
}