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
    HomeBerandaPage(), // 0 - Beranda
    SocialPage(),      // 1 - Sosial
    ToolsPage(),       // 2 - Tools
    ProfilePage(),     // 3 - Profil
  ];

  void _openAiAssistant() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const AiPage()));
  }

  void _openAddMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: _pages[_currentIndex],
      floatingActionButton: _currentIndex == 0
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // AI Assistant FAB
                FloatingActionButton(
                  heroTag: 'fab_ai',
                  onPressed: _openAiAssistant,
                  backgroundColor: Colors.black87,
                  elevation: 4,
                  shape: const CircleBorder(),
                  child: const Icon(
                    Icons.smart_toy_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(height: 12),
                // Add FAB (Fitur dari GitHub)
                FloatingActionButton(
                  heroTag: 'fab_add',
                  onPressed: _openAddMenu,
                  backgroundColor: Colors.white,
                  elevation: 4,
                  shape: const CircleBorder(),
                  child: const Icon(
                    Icons.add_rounded,
                    color: Colors.black87,
                    size: 28,
                  ),
                ),
              ],
            )
          : null,
      bottomNavigationBar: HomeBottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

// --- Widget Pendukung (Bottom Sheet dari versi GitHub) ---

class _AddBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tambah Baru',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
          ),
          const SizedBox(height: 16),
          _SheetOption(
            icon: Icons.calendar_today_rounded,
            label: 'Jadwal',
            subtitle: 'Tambah jadwal belajar',
            onTap: () {
              Navigator.pop(context);
              // TODO: navigate to add schedule
            },
          ),
          const SizedBox(height: 10),
          _SheetOption(
            icon: Icons.task_alt_rounded,
            label: 'Tugas',
            subtitle: 'Tambah tugas baru',
            onTap: () {
              Navigator.pop(context);
              // TODO: navigate to add task
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _SheetOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _SheetOption({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}