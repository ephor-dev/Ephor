import 'package:ephor/data/repositories/auth/auth_repository.dart';
import 'package:ephor/data/repositories/catna/catna_repository.dart';
import 'package:ephor/data/repositories/employee/employee_repository.dart';
import 'package:ephor/data/repositories/form/form_repository.dart';
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
    ChangeNotifierProvider<EmployeeRepository>(
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
    ChangeNotifierProvider<FormRepository>(
      create: (context) => FormRepository(
        supabaseService: context.read()
      ),
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