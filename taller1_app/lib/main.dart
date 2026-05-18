import 'package:flutter/material.dart';
import 'package:taller1_app/routes/app_router.dart';

import 'auth/auth_controller.dart';
import 'auth/auth_scope.dart';
import 'themes/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AuthController _authController;

  @override
  void initState() {
    super.initState();
    _authController = AuthController();
    _authController.loadStoredSession();
  }

  @override
  void dispose() {
    _authController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScope(
      controller: _authController,
      child: MaterialApp.router(
        theme: AppTheme.lightTheme,
        title: 'Flutter - UCEVA',
        routerConfig: appRouter,
      ),
    );
  }
}
