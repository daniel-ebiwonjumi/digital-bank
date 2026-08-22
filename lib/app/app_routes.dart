import 'package:go_router/go_router.dart';
import 'package:social_and_recommendation_system/ui/auth/login_screen.dart';
import 'package:social_and_recommendation_system/ui/auth/signup_screen.dart';

class AppRoutes {
  static const String home = 'home';
  static const String login = '/';
  static const String signup = 'signup';
}

final GoRouter router = GoRouter(
initialLocation: '/login',

  routes: <RouteBase>[
GoRoute(name: AppRoutes.login,
  path: '/login',
builder: (context, state){
  return const LoginScreen();
},),

  GoRoute(
    name: AppRoutes.signup,
    path: '/signup',
  builder: (context, state) => const SignupScreen()),

  GoRoute(
    name: AppRoutes.home,
    path: '/home',
  builder: (context, state) => const SignupScreen()),
]
);