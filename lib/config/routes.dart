import 'package:flutter/material.dart';
import 'package:tick_it/models/task_model.dart';
import 'package:tick_it/screens/splash_screen.dart';
import 'package:tick_it/screens/login_screen.dart';
import 'package:tick_it/screens/signup_screen.dart';
import 'package:tick_it/screens/home_screen.dart';
import 'package:tick_it/screens/create_task_screen.dart';
import 'package:tick_it/screens/edit_task_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String createTask = '/create-task';
  static const String editTask = '/edit-task';
}

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
      case AppRoutes.createTask:
        final date = settings.arguments as DateTime?;
        return _buildPageRoute(CreateTaskScreen(initialDate: date), settings);
      case AppRoutes.editTask:
        final task = settings.arguments as TaskModel;
        return _buildPageRoute(EditTaskScreen(task: task), settings);
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
