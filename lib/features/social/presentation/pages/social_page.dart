import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ploopy/features/chat/presentation/pages/chat_page.dart';
import 'package:ploopy/features/event/presentation/pages/event_detail_page.dart';
import 'package:ploopy/features/social/presentation/pages/create_activity_page.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/social_tab_bar.dart';
import '../widgets/social_activity_tab.dart';
import '../widgets/social_event_tab.dart';
import '../widgets/social_preferences_sheet.dart';

class SocialPage extends StatefulWidget {
  const SocialPage({super.key});

  @override
  State<SocialPage> createState() => _SocialPageState();
}

class _SocialPageState extends State<SocialPage> {
  SocialTab _currentTab = SocialTab.activity;

  void _openSearch() {
    HapticFeedback.lightImpact();
    // TODO: Implement search
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Fitur pencarian dalam pengembangan 🔍',
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 12),
        ),
        backgroundColor: Colors.grey.shade800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _openNotifications() {
    HapticFeedback.lightImpact();
    // TODO: Implement notifications
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Notifikasi dalam pengembangan 🔔',
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 12),
        ),
        backgroundColor: Colors.grey.shade800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _openChat() {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ChatPage()),
    );
  }

  void _openCreateActivity() {
    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateActivityPage()),
    ).then((_) => setState(() {})); // Refresh after creating
  }

  void _openCreateEvent() {
    HapticFeedback.mediumImpact();
    // TODO: Navigate to create event page
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Fitur buat event dalam pengembangan 📅',
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 12),
        ),
        backgroundColor: Colors.grey.shade800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _openPreferences() {
    HapticFeedback.lightImpact();
    SocialPreferencesSheet.show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        _buildAppBar(),
        SocialTabBar(
          selected: _currentTab,
          onChanged: (tab) => setState(() => _currentTab = tab),
        ),
        Expanded(child: _buildContent()),
      ],
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
      child: Row(
        children: [
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Social',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ),
          _buildIconButton(icon: Icons.search_rounded, onTap: _openSearch),
          _buildIconButton(
            icon: Icons.notifications_outlined,
            onTap: _openNotifications,
            badge: 3, // Contoh badge count
          ),
          _buildIconButton(
            icon: Icons.chat_bubble_outline_rounded,
            onTap: _openChat,
          ),
          _buildIconButton(
            icon: Icons.more_vert_rounded,
            onTap: _openPreferences,
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
    int? badge,
  }) {
    return Stack(
      children: [
        IconButton(
          icon: Icon(icon, color: Colors.grey.shade700, size: 22),
          onPressed: onTap,
        ),
        if (badge != null && badge > 0)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red.shade500,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                badge > 9 ? '9+' : '$badge',
                style: GoogleFonts.poppins(
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildContent() {
    switch (_currentTab) {
      case SocialTab.activity:
        return SocialActivityTab(
          onCreatePost: _openCreateActivity,
          onTapPost: (activity) {
            // TODO: Open activity detail
          },
        );
      case SocialTab.event:
        return SocialEventTab(
          onTapEvent: (event) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => EventDetailPage(event: event)),
            );
          },
          onCreateEvent: _openCreateEvent,
        );
    }
  }
}
