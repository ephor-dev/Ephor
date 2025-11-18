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
  }

  runApp(
    MultiProvider(
      providers: providers,
      child: EphorApp(),
    )
  );
}

class EphorApp extends StatefulWidget {
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
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      SupabaseConfig.forceLogOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = createTextTheme(context, "Ubuntu", "Lato");
    EphorTheme ephorTheme = EphorTheme(textTheme);

    return MaterialApp.router(
      scrollBehavior: MaterialScrollBehavior(),
      theme: ephorTheme.light(),
      darkTheme: ephorTheme.dark(),
      themeMode: ThemeMode.light,
      routerConfig: router(context.read()),
    );
  }
}