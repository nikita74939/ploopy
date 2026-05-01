import 'package:flutter/material.dart';
import 'package:ploopy/features/home/presentation/widgets/home_page.dart';
import '../../../ai/presentation/pages/ai_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../social/presentation/pages/social_page.dart';
import '../../../tools/presentation/pages/tools_page.dart';
import '../widgets/home_bottom_nav.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeBerandaPage(),
    SocialPage(),
    ToolsPage(),
    ProfilePage(),
  ];

  void _openAiAssistant() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const AiPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: _pages[_currentIndex],
      floatingActionButton:
          _currentIndex == 0
              ? FloatingActionButton(
                onPressed: _openAiAssistant,
                backgroundColor: Colors.black87,
                elevation: 4,
                shape: const CircleBorder(),
                child: const Icon(
                  Icons.smart_toy_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              )
              : null,
      bottomNavigationBar: HomeBottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}