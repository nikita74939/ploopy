// lib/core/router/app_router.dart

import 'package:flutter/material.dart';
import '../../features/home/presentation/pages/home_screen.dart';
import '../../features/study_desk/presentation/pages/study_desk_page.dart';

class AppRouter {
  static const String home = '/';
  static const String studyDesk = '/study-desk';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case studyDesk:
        return MaterialPageRoute(
          builder: (_) => const StudyDeskPage(),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route: ${settings.name}')),
          ),
        );
    }
  }
}