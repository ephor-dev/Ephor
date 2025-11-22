// 1. IMPORT the ImpactAssessmentForm file (Assuming it's in a path like 'ui/forms/impact_assessment_form.dart')
import 'package:ephor/config/dependencies.dart';
import 'package:ephor/ui/core/themes/theme_util.dart';
import 'package:ephor/config/supabase_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'ui/core/themes/theme.dart';
import 'routing/router.dart';

// === CORRECTED NEW IMPORT ===
// We convert the file system path (C:/Users/torin/Ephor/lib/...) 
// into a package path (package:ephor/...)
import 'package:ephor/ui/IA_form/view/IA_form_view.dart';
// If the widget name is different from ImpactAssessmentForm, 
// you must update the name below!
// ============================

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  try {
    await SupabaseConfig.initialize();
  } catch (e) {
    debugPrint('Error initializing Supabase: $e');
  }

  runApp(
    MultiProvider(
      providers: providers,
      child: EphorApp(),
    )
  );
}

class EphorApp extends StatefulWidget {
  const EphorApp({super.key});

  @override
  State<EphorApp> createState() => _EphorState();
}

class _EphorState extends State<EphorApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // === TEMPORARY CHANGE HERE ===
    // To run your form directly, return it instead of the Material App.
    // COMMENT OUT the entire routing/theming logic for testing.
    
    // return MaterialApp.router(...);
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      // Assuming the widget in IA_form_view.dart is named ImpactAssessmentForm
      home: ImpactAssessmentForm(),
    );
    
    // =============================
    
    /* // ORIGINAL CODE (commented out for form testing)
    TextTheme textTheme = createTextTheme(context, "Ubuntu", "Lato");
    EphorTheme ephorTheme = EphorTheme(textTheme);

    return MaterialApp.router(
      scrollBehavior: MaterialScrollBehavior(),
      debugShowCheckedModeBanner: false,
      theme: ephorTheme.light(),
      darkTheme: ephorTheme.dark(),
      themeMode: ThemeMode.light,
      routerConfig: router(context.read()),
    );
    */
  }
}