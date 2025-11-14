import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:ephor/data/repositories/auth/auth_repository.dart';
// import '../data/repositories/auth/auth_repository.dart';
// import '../ui/activities/view_models/activities_viewmodel.dart';
// import '../ui/activities/widgets/activities_screen.dart';
import '../ui/login/login_viewmodel/login_viewmodel.dart';
import '../ui/login/login_view/login_view.dart';
// import '../ui/booking/view_models/booking_viewmodel.dart';
// import '../ui/booking/widgets/booking_screen.dart';
// import '../ui/home/view_models/home_viewmodel.dart';
// import '../ui/home/widgets/home_screen.dart';
// import '../ui/results/view_models/results_viewmodel.dart';
// import '../ui/results/widgets/results_screen.dart';
// import '../ui/search_form/view_models/search_form_viewmodel.dart';
// import '../ui/search_form/widgets/search_form_screen.dart';
import 'routes.dart';

GoRouter router(AuthRepository authRepository) => GoRouter(
  initialLocation: Routes.home,
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
  ],
);

// From https://github.com/flutter/packages/blob/main/packages/go_router/example/lib/redirection.dart
Future<String?> _redirect(BuildContext context, GoRouterState state) async {
  // if the user is not logged in, they need to login
  final loggedIn = await context.read<AuthRepository>().isAuthenticated;
  final loggingIn = state.matchedLocation == Routes.login;
  if (!loggedIn) {
    return Routes.login;
  }

  // if the user is logged in but still on the login page, send them to
  // the home page
  if (loggingIn) {
    return Routes.home;
  }

  // no need to redirect at all
  return null;
}