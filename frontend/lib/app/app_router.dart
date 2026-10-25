import 'package:digital_bank/ui/auth/auth_view_model.dart';
import 'package:digital_bank/ui/auth/bloc/auth_bloc.dart';
import 'package:digital_bank/ui/auth/bloc/auth_state.dart';
import 'package:digital_bank/ui/home/home_view.dart';
import 'package:go_router/go_router.dart';
import 'package:digital_bank/ui/auth/login_view.dart';
import 'package:digital_bank/ui/auth/register_view.dart';
import 'package:digital_bank/ui/home/home_view_model.dart';

class AppRouter {
  late final GoRouter router;
  final AuthBloc authBloc;

  AppRouter(this.authBloc) {
    router = GoRouter(
      initialLocation: '/',
      refreshListenable: _authRefreshNotifier,

      routes: <RouteBase>[
        GoRoute(
          name: AppRoutes.login,
          path: '/',
          builder: (context, state) {
            return LoginView();
          },
        ),

        GoRoute(
          name: AppRoutes.register,
          path: '/register',
          builder: (context, state) => RegisterView(),
        ),

        GoRoute(
          name: AppRoutes.home,
          path: '/home',
          builder: (context, state) => HomeView(),
        ),
      ],

      redirect: (context, state) {
        final status = authBloc.state.status;
        final currentLoc = state.matchedLocation;

        if (status == AuthStatus.loading) {
          return '/';
        }
        if (status == AuthStatus.unauthenticated) {
          if (currentLoc == '/register') return null;
          return currentLoc == '/login' ? null : '/login';
        }

        if (status == AuthStatus.authenticated) {
          if (currentLoc == '/' ||
              currentLoc == '/login' ||
              currentLoc == '/register') {
            return '/home';
          }
        }
        return null;
      },
    );
  }
  void dispose() {
    router.dispose();
    _authRefreshNotifier.dispose();
  }
}

class AppRoutes {
  static const String home = 'home';
  static const String login = '/';
  static const String register = 'register';
}
