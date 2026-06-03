import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../social/presentation/pages/social_page.dart';
import '../../../tools/presentation/pages/tools_page.dart';
import '../widgets/home_bottom_nav.dart';
import '../widgets/home_page.dart' show HomePage;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    SocialPage(),
    ToolsPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _pages[_currentIndex],
      bottomNavigationBar: HomeBottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}
