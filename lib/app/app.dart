import 'dart:ui';

import 'package:ephor/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view/auth/auth_gate.dart'; // Import the new AuthGate
import '../view/login/login_view_model.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  
  @override
  State<MyApp> createState() => _EphorAppState();
}

class _EphorAppState extends State<MyApp> {
  late final AppLifecycleListener _listener;

  @override
  void initState() {
    super.initState();
    _listener = AppLifecycleListener(onExitRequested: _handleExitRequest);
  }

  @override
  void dispose() {
    _listener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LoginViewModel(),
      child: MaterialApp(
        title: 'Flutter MVVM App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        // The AuthGate is now the single source of truth.
        home: const AuthGate(),
      ),
    );
  }

  Future<AppExitResponse> _handleExitRequest() async {
    // final AppExitResponse response = _shouldExit ? AppExitResponse.exit : AppExitResponse.cancel;
    // setState(() {
    //   _lastExitResponse = 'App responded ${response.name} to exit request';
    // });

    await supabase.auth.signOut();
    return AppExitResponse.exit;
  }
}