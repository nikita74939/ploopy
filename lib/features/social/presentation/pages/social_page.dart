import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/social_dummy_data.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/social_filter_tabs.dart';
import '../widgets/social_post_card.dart';

class SocialPage extends StatefulWidget {
  const SocialPage({super.key});

  @override
  State<SocialPage> createState() => _SocialPageState();
}

class _SocialPageState extends State<SocialPage> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final posts =
        _selectedTab == 0
            ? SocialDummyData.forYouPosts
            : SocialDummyData.friendsPosts;

    return SafeArea(
      child: Column(
        children: [
          _buildAppBar(),
          SocialFilterTabs(
            selectedIndex: _selectedTab,
            onChanged: (i) => setState(() => _selectedTab = i),
          ),
          Expanded(
            child:
                posts.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: () async {
                        await Future.delayed(const Duration(seconds: 1));
                      },
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(
                          16,
                          16,
                          16,
                          80,
                        ), // ⭐ UPDATE
                        children: [
                          ...posts.map((p) => SocialPostCard(post: p)).toList(),
                        ],
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100, width: 1),
        ),
      ),
      child: Row(
        children: [
          Text(
            'Ploopy',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          const Spacer(),
          _iconButton(Icons.search_rounded, () {}),
          const SizedBox(width: 10),
          _iconButton(Icons.notifications_outlined, () {}, badge: true),
        ],
      ),
    );
  }

  Widget _iconButton(IconData icon, VoidCallback onTap, {bool badge = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: Colors.black87),
          ),
          if (badge)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Text('👥', style: TextStyle(fontSize: 36)),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada postingan',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Follow temanmu untuk lihat aktivitas mereka',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
