import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:automation_app/providers/auth_provider.dart';
import 'package:automation_app/screens/splash_screen.dart';
import 'package:automation_app/screens/login_screen.dart';
import 'package:automation_app/screens/home_screen.dart';
import 'package:automation_app/utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const AutomationApp(),
    ),
  );
}

class AutomationApp extends StatelessWidget {
  const AutomationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Automation App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    if (authProvider.isLoading) {
      return const SplashScreen();
    }
    if (authProvider.user == null) {
      return const LoginScreen();
    }
    return const HomeScreen();
  }
}
