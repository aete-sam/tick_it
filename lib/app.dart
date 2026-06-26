import 'package:flutter/material.dart';
import 'package:tick_it/config/theme.dart';
import 'package:tick_it/config/routes.dart';

class TickItApp extends StatelessWidget {
  const TickItApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TickIt',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
