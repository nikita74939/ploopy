// ignore_for_file: dead_code

import 'package:flutter/material.dart';
import 'package:ploopy/features/home/presentation/pages/calender_page.dart';
import 'package:ploopy/features/home/presentation/pages/home_screen.dart';
import 'package:ploopy/features/schedule/presentation/add_schedule_page.dart';
import 'package:ploopy/features/schedule/presentation/add_task_page.dart';
import 'package:ploopy/features/notification/presentation/pages/notification_page.dart';
import 'package:ploopy/shared/services/activity_service.dart';
import 'package:ploopy/shared/services/event_service.dart';
import 'package:ploopy/features/auth/presentation/pages/auth_screen.dart';
import 'package:ploopy/shared/services/session_service.dart';
import 'package:ploopy/core/theme/app_theme.dart';
import 'package:ploopy/features/study_desk/presentation/pages/study_desk_page.dart';

class PloopyApp extends StatelessWidget {
  const PloopyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ploopy',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const SplashDecider(),
      onGenerateRoute: _generateRoute,
    );
  }

  static Route<dynamic> _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/study-desk':
        return MaterialPageRoute(builder: (_) => const StudyDeskPage());
        break;
      case '/calendar':
        return MaterialPageRoute(builder: (_) => const CalendarPage());
        break;
      case '/notification':
        return MaterialPageRoute(builder: (_) => const NotificationPage());
        break;
      case '/add-schedule':
        return MaterialPageRoute(builder: (_) => const AddSchedulePage());
        break;
      case '/add-task':
        return MaterialPageRoute(builder: (_) => const AddTaskPage());
        break;
      default:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
    }
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
    _initSampleData();
  }

  Future<void> _initSampleData() async {
    await ActivityService.addSampleData();
    await EventService.addSampleData();
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
