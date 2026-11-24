import 'dart:async';
import 'package:digital_bank/features/auth/bloc/auth_bloc.dart';
import 'package:digital_bank/features/auth/bloc/auth_state.dart';
import 'package:digital_bank/features/auth/login_view.dart';
import 'package:digital_bank/features/auth/register_view.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';


class AppRouter {
  final AuthBloc authBloc;
  late final GoRouter router;
  late final _AuthRefreshNotifier _authRefreshNotifier;

  AppRouter(this.authBloc) {
    _authRefreshNotifier = _AuthRefreshNotifier(authBloc);
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
        final status = authBloc.state;
        final currentLoc = state.matchedLocation;

        if (status is AuthLoading) {
          return '/';
        }
        if (status is Unauthenticated) {
          if (currentLoc == '/register') return null;
          return currentLoc == '/' ? null : '/';
        }

        if (status is Authenticated) {
          if (currentLoc == '/' ||
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


// Provide the repository (switch with --dart-define=USE_MOCK_PAYMENTS=true)
RepositoryProvider<FundAccountRepository>(
  create: (_) => const bool.fromEnvironment('USE_MOCK_PAYMENTS')
      ? MockFundAccountRepository()
      : FundAccountRepositoryImpl(FundAccountService(dio)),
  child: ...,
)

// Routes
GoRoute(
  path: '/fund-account',
  builder: (_, __) => const FundAccountPage(),
  routes: [
    GoRoute(
      path: 'checkout',
      builder: (_, state) =>
          PaymentWebViewPage(checkoutUrl: state.extra! as String),
    ),
  ],
),

// Home screen: refresh the balance when Fund account pops with true
final refresh = await context.push<bool>('/fund-account');
if (refresh == true && context.mounted) {
  context.read<HomeBloc>().add(const HomeRefreshRequested()); // use your event name
}