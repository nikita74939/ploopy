import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ploopy/features/chat/presentation/pages/chat_page.dart';
import 'package:ploopy/features/event/presentation/pages/event_detail_page.dart';
import 'package:ploopy/features/notification/presentation/pages/notification_page.dart';
import 'package:ploopy/features/social/presentation/pages/create_activity_page.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../widgets/social_activity_tab.dart';
import '../widgets/social_event_tab.dart';
import '../widgets/social_preferences_sheet.dart';
import '../widgets/social_tab_bar.dart';

class SocialPage extends StatefulWidget {
  const SocialPage({super.key});

  @override
  State<SocialPage> createState() => _SocialPageState();
}

class _SocialPageState extends State<SocialPage> {
  SocialTab _currentTab = SocialTab.activity;

  void _openSearch() {
    HapticFeedback.lightImpact();
    _showSnackBar('Fitur pencarian dalam pengembangan');
  }

  void _openNotifications() {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationPage()),
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
    ).then((_) => setState(() {}));
  }

  void _openCreateEvent() {
    HapticFeedback.mediumImpact();
    _showSnackBar('Fitur buat event dalam pengembangan');
  }

  void _openPreferences() {
    HapticFeedback.lightImpact();
    SocialPreferencesSheet.show(context);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTextStyles.small.copyWith(color: AppColors.white),
        ),
        backgroundColor: AppColors.black,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyLighter,
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
      padding: const EdgeInsets.fromLTRB(16, 10, 12, 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Social',
              style: AppTextStyles.heading.copyWith(
                fontSize: 18,
                color: AppColors.black,
              ),
            ),
          ),
          _buildIconButton(icon: Icons.search_rounded, onTap: _openSearch),
          _buildIconButton(
            icon: Icons.notifications_outlined,
            onTap: _openNotifications,
            badge: 3,
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
          icon: Icon(icon, color: AppColors.grey, size: 21),
          onPressed: onTap,
          splashRadius: 22,
        ),
        if (badge != null && badge > 0)
          Positioned(
            right: 7,
            top: 7,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.black,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
              child: Text(
                badge > 9 ? '9+' : '$badge',
                style: AppTextStyles.small.copyWith(
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
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
          onTapPost: (activity) {},
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
