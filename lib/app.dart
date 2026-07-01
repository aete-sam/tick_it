import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tick_it/config/theme.dart';
import 'package:tick_it/config/routes.dart';
import 'package:tick_it/providers/auth_provider.dart';
import 'package:tick_it/providers/task_provider.dart';

class TickItApp extends StatelessWidget {
  const TickItApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
      ],
      child: MaterialApp(
        title: 'TickIt',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}
