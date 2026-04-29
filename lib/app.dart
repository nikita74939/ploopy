import 'package:flutter/material.dart';
import 'package:ploopy/features/home/presentation/pages/home_screen.dart';
import 'features/auth/presentation/pages/auth_screen.dart';
import 'shared/services/session_service.dart';
import 'core/theme/app_theme.dart';

class PloopyApp extends StatelessWidget {
  const PloopyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ploopy',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const SplashDecider(),
    );
  }
}

class SplashDecider extends StatefulWidget {
  const SplashDecider({super.key});

  @override
  State<SplashDecider> createState() => _SplashDeciderState();
}

class _SplashDeciderState extends State<SplashDecider> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final isLoggedIn = await SessionService.isLoggedIn();
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      ),
    );
  }
}