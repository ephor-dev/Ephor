import 'package:ephor/ui/add_employee/view/add_employee_view.dart';
import 'package:ephor/ui/add_employee/view_model/add_employee_viewmodel.dart';
import 'package:ephor/ui/dashboard/subviews/finished_assessment/view/finished_assessment_subview.dart';
import 'package:ephor/ui/dashboard/subviews/finished_assessment/view_model/finished_assessment_viewmodel.dart';
import 'package:ephor/ui/dashboard/subviews/finished_trainings/view/finished_trainings_subview.dart';
import 'package:ephor/ui/dashboard/subviews/finished_trainings/view_model/finished_trainings_viewmodel.dart';
import 'package:ephor/ui/dashboard/subviews/overview/view/overview_subview.dart';
import 'package:ephor/ui/dashboard/subviews/overview/view_model/overview_viewmodel.dart';
import 'package:ephor/ui/dashboard/subviews/recommended_trainings/view/recommended_trainings_subview.dart';
import 'package:ephor/ui/dashboard/subviews/recommended_trainings/view_model/recommended_trainings_viewmodel.dart';
import 'package:ephor/ui/dashboard/subviews/upcoming_schedules/view/upcoming_schedules_subview.dart';
import 'package:ephor/ui/dashboard/subviews/upcoming_schedules/view_model/upcoming_schedules_viewmodel.dart';
import 'package:ephor/ui/dashboard/view_model/dashboard_viewmodel.dart';
import 'package:ephor/ui/employee_management/view/employees_view.dart';
import 'package:ephor/ui/employee_management/view_model/employees_viewmodel.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:ephor/data/repositories/auth/auth_repository.dart';
import 'package:ephor/ui/login/view_model/login_viewmodel.dart';
import 'package:ephor/ui/login/view/login_view.dart';
import 'package:ephor/ui/dashboard/view/dashboard_view.dart';
import 'routes.dart';

GoRouter router(AuthRepository authRepository) => GoRouter(
  initialLocation: Routes.dashboard,
  debugLogDiagnostics: true,
  redirect: _redirect,
  refreshListenable: authRepository,
  routes: [
    GoRoute(
      path: Routes.login,
      builder: (context, state) {
        return LoginView(
          viewModel: LoginViewModel(authRepository: context.read()),
        );
      },
    ),
    ShellRoute(
      builder: (BuildContext context, GoRouterState state, Widget child) {
        return DashboardView(
          viewModel: DashboardViewModel(authRepository: context.read()),
          child: child
        );
      },
      routes: [
        GoRoute(
          path: Routes.dashboard,
          redirect: (context, state) => Routes.getOverviewPath(),
        ),
        GoRoute(
          path: Routes.getOverviewPath(),
          builder: (context, state) => OverviewSubView(
            viewModel: OverviewViewModel(), 
          ),
        ),
        GoRoute(
          path: Routes.getEmployeeListPath(),
          builder: (context, state) => EmployeeListSubView(
            viewModel: EmployeeListViewModel(
              employeeRepository: context.read(),
              authRepository: authRepository
            ),
          ),
          routes: [
            GoRoute(
              path: Routes.dashboardAddEmployee,
              builder: (context, state) => AddEmployeeView(
                viewModel: AddEmployeeViewModel(
                  employeeRepository: context.read(),
                  authRepository: authRepository
                )
              )
            )
          ]
        ),
        GoRoute(
          path: Routes.getSchedulesPath(),
          builder: (context, state) => UpcomingSchedulesSubView(
            viewModel: UpcomingSchedulesViewModel(),
          ),
        ),
        GoRoute(
          path: Routes.getAssessmentsPath(),
          builder: (context, state) => FinishedAssessmentsSubView(
            viewModel: FinishedAssessmentsViewModel(),
          ),
        ),
        GoRoute(
          path: Routes.getFinishedTrainingsPath(),
          builder: (context, state) => FinishedTrainingsSubView(
            viewModel: FinishedTrainingsViewModel(),
          ),
        ),
        GoRoute(
          path: Routes.getRecommendedTrainingsPath(),
          builder: (context, state) => RecommendedTrainingsSubView(
            viewModel: RecommendedTrainingsViewModel(),
          ),
        ),
      ]
    )
  ],
);

Future<String?> _redirect(BuildContext context, GoRouterState state) async {
  // if the user is not logged in, they need to login
  final loggedIn = await context.read<AuthRepository>().isAuthenticated;
  final loggingIn = state.matchedLocation == Routes.login;
  if (!loggedIn) {
    return Routes.login;
  }

  if (loggingIn) {
    return Routes.dashboard;
  }

  return null;
}