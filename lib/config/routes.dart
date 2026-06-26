import 'package:flutter/material.dart';
import 'package:tick_it/screens/splash_screen.dart';
import 'package:tick_it/screens/login_screen.dart';
import 'package:tick_it/screens/signup_screen.dart';
import 'package:tick_it/screens/home_screen.dart';

/// Named route constants
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
}

/// Route generator
class AppRouter {
  AppRouter._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return _buildPageRoute(const SplashScreen(), settings);
      case AppRoutes.login:
        return _buildPageRoute(const LoginScreen(), settings);
      case AppRoutes.signup:
        return _buildPageRoute(const SignupScreen(), settings);
      case AppRoutes.home:
        return _buildPageRoute(const HomeScreen(), settings);
      default:
        return _buildPageRoute(const SplashScreen(), settings);
    }
  }

  static PageRouteBuilder _buildPageRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }
}
