import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../main.dart';
import '../admin_dashboard/admin_dashboard_view.dart';
import '../login/login_view.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  StreamSubscription<AuthState>? _authSubscription;
  Session? _session;

  @override
  void initState() {
    super.initState();
    // This is a hack to ensure the initial session is loaded
    // before the first frame is rendered.
    // A proper fix is being worked on by the Supabase team.
    WidgetsBinding.instance.addPostFrameCallback((_) => _setupAuthListener());
  }

  void _setupAuthListener() {
    // Listen to auth state changes
    _authSubscription = supabase.auth.onAuthStateChange.listen((data) {
      setState(() {
        _session = data.session;
      });
    });

    // Also set the initial session
    setState(() {
      _session = supabase.auth.currentSession;
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Based on the session, return the appropriate screen
    return _session != null ? const DashboardView() : LoginView();
  }
}