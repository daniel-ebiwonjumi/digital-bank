import 'dart:async';
import 'package:digital_bank/ui/auth/bloc/auth_bloc.dart';
import 'package:digital_bank/ui/auth/bloc/auth_state.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:digital_bank/ui/auth/login_view.dart';
import 'package:digital_bank/ui/auth/register_view.dart';

class AppRouter {
  final AuthBloc authBloc;
  late final GoRouter router;
  late final _AuthRefreshNotifier _authRefreshNotifier;

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

class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(AuthBloc authBloc) {
    _subscription = authBloc.stream.listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class AppRoutes {
  static const String home = 'home';
  static const String login = '/';
  static const String register = 'register';
}
