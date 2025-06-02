import 'package:flutter/material.dart';
import 'package:safenest/screens/splash_screen.dart';
import 'package:safenest/screens/auth/login_screen.dart';
import 'package:safenest/screens/auth/register_screen.dart';
import 'package:safenest/screens/onboarding/onboarding_screen.dart';
import 'package:safenest/screens/home/home_screen.dart';
import 'package:safenest/screens/map/danger_map_screen.dart';
import 'package:safenest/screens/safecircle/safecircle_screen.dart';
import 'package:safenest/screens/settings/settings_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String dangerMap = '/danger-map';
  static const String safeCircle = '/safe-circle';
  static const String settings = '/settings';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case dangerMap:
        return MaterialPageRoute(builder: (_) => const DangerMapScreen());
      case safeCircle:
        return MaterialPageRoute(builder: (_) => const SafeCircleScreen());
      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
} 