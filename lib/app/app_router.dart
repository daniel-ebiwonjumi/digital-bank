import 'package:digital_bank/ui/auth/auth_view_model.dart';
import 'package:digital_bank/ui/home/home_view.dart';
import 'package:go_router/go_router.dart';
import 'package:digital_bank/ui/auth/login_view.dart';
import 'package:digital_bank/ui/auth/register_view.dart';

class AppRouter {
  final AuthViewModel authViewModel;
  late final GoRouter router;
final HomeViewModel homeViewModel;

  AppRouter({required this.authViewModel, required this.homeViewModel}) {
    router = GoRouter(
      initialLocation: '/',
      refreshListenable: authViewModel,

      routes: <RouteBase>[
        GoRoute(
          name: AppRoutes.login,
          path: '/',
          builder: (context, state) {
            return LoginView(authViewModel);
          },
        ),

        GoRoute(
          name: AppRoutes.register,
          path: '/register',
          builder: (context, state) =>
              RegisterView(authViewModel),
        ),

        GoRoute(
          name: AppRoutes.home,
          path: '/home',
          builder: (context, state) =>
              HomeView(authViewModel: authViewModel, homeViewModel: homeViewModel),
        ),
      ],

      redirect: (context, state) {
        final status = authViewModel.status;
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
}

class AppRoutes {
  static const String home = 'home';
  static const String login = '/';
  static const String register = 'register';
}

                    
                       
                                  
                           
                  