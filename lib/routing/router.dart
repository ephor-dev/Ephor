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
import 'package:ephor/ui/edit_employee/view/edit_employee_view.dart';
import 'package:ephor/ui/edit_employee/view_model/edit_employee_viewmodel.dart';
import 'package:ephor/ui/employee_management/view/employees_view.dart';
import 'package:ephor/ui/employee_management/view_model/employees_viewmodel.dart';
import 'package:ephor/ui/password_update/forgot_password/view/forgot_password_view.dart';
import 'package:ephor/ui/password_update/forgot_password/view_model/forgot_password_viewmodel.dart';
import 'package:ephor/ui/password_update/update_password/view/update_password_view.dart';
import 'package:ephor/ui/password_update/update_password/view_model/update_password_viewmodel.dart';
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
          viewModel: LoginViewModel(
            authRepository: context.read(),
            prefsRepository: context.read()
          ),
        );
      },
    ),
    GoRoute(
      path: Routes.forgotPassword,
      builder: (context, state) {
        return ForgotPasswordView(
          viewModel: ForgotPasswordViewModel(
            authRepository: context.read(),
          )
        );
      }
    ),
    GoRoute(
      path: Routes.updatePassword,
      builder: (context, state) {
        return UpdatePasswordView(
          viewModel: UpdatePasswordViewModel(
            authRepository: context.read()
          )
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
            ),
            GoRoute(
              path: Routes.dashboardEditEmployee,
              name: 'edit_employee',
              builder: (context, state) {
                final param = state.uri.queryParameters['fromUser'];
                final isFromUser = param == 'true';
                final code = state.uri.queryParameters['code'];

                return EditEmployeeView(
                  viewModel: EditEmployeeViewModel(
                    employeeRepository: context.read(),
                    fromUserQuery: isFromUser,
                    targetEmployeeCode: code ?? 'Unknown'
                  ),
                );
              },
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
  final authRepo = context.read<AuthRepository>();
  final loggedIn = await authRepo.isAuthenticated;

  final loggingIn = state.matchedLocation == Routes.login;
  final recoveringPassword = state.matchedLocation == Routes.forgotPassword;
  final updatingPassword = state.matchedLocation == Routes.updatePassword;

  // 1. Not logged in → allow reset flow
  if (!loggedIn) {
    if (loggingIn || recoveringPassword || updatingPassword) {
      return null;
    }

    return Routes.login;
  }

  if (loggedIn && updatingPassword) {
    return null;
  }

  // 2. Logged in but clicked reset email → redirect to update screen
  if (authRepo.isPasswordRecoveryMode) {
    if (!updatingPassword) return Routes.updatePassword;
    return null;
  }

  // 3. Logged in normally → prevent returning to login/reset pages
  if (loggingIn || recoveringPassword || updatingPassword) {
    return Routes.dashboard;
  }

  return null;
}