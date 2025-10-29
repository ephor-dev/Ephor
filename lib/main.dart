import 'package:ephor/config/dependencies.dart';
import 'package:ephor/ui/core/themes/theme_util.dart';
import 'package:ephor/config/supabase_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'ui/core/themes/theme.dart';
import 'routing/router.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  try {
    await SupabaseConfig.initialize();
  } catch (e) {
    debugPrint('Error initializing Supabase: $e');
    // You can handle the error here - maybe show an error screen
    // or continue without Supabase (not recommended for production)
  }

  runApp(
    MultiProvider(
      providers: providers,
      child: MyApp(),
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // The application's primary theme configuration
  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = createTextTheme(context, "Ubuntu", "Lato");
    EphorTheme ephorTheme = EphorTheme(textTheme);

    return MaterialApp.router(
      scrollBehavior: MaterialScrollBehavior(),
      theme: ephorTheme.light(),
      darkTheme: ephorTheme.light(),
      themeMode: ThemeMode.system,
      routerConfig: router(context.read()),
    );
  }
}
// Set your DashboardWidget as the default screen
// // FIX: Removed 'const' keyword to resolve the "Not a constant expression" error.
// home: Widgets(), 