import 'package:ephor/data/repositories/employee/employee_repository.dart';
import 'package:ephor/data/repositories/shared_prefs/abstract_prefs_repository.dart';
import 'package:ephor/ui/core/themes/theme_mode_notifier.dart';
import 'package:flutter/material.dart';
import 'package:ephor/ui/dashboard/view/dashboard_view.dart';
import 'package:ephor/ui/dashboard/view_model/dashboard_viewmodel.dart';
import 'package:ephor/data/repositories/auth/auth_repository.dart';

class DashboardContainer extends StatefulWidget {
  final Widget child;
  final AuthRepository authRepository;
  final AbstractPrefsRepository prefsRepository;
  final EmployeeRepository employeeRepository;
  final ThemeModeNotifier themeNotifier;

  const DashboardContainer({
    super.key,
    required this.child,
    required this.authRepository,
    required this.prefsRepository,
    required this.employeeRepository,
    required this.themeNotifier,
  });

  @override
  State<DashboardContainer> createState() => _DashboardContainerState();
}

class _DashboardContainerState extends State<DashboardContainer> {
  late final DashboardViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = DashboardViewModel(
      authRepository: widget.authRepository,
      prefsRepository: widget.prefsRepository,
      themeNotifier: widget.themeNotifier, 
      employeeRepository: widget.employeeRepository,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DashboardView(
      viewModel: _viewModel,
      child: widget.child,
    );
  }
}