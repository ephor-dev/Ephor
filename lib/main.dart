import 'package:ephor/config/dependencies.dart';
import 'package:ephor/ui/core/themes/theme_util.dart';
import 'package:ephor/config/supabase_config.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ui/core/themes/theme.dart';
import 'routing/router.dart';

void main() async {
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

  // This widget is the root of your application.
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