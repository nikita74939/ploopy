import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/pages/auth_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../bloc/profile_bloc.dart';
import '../widgets/profile_achievement_section.dart';
import '../widgets/profile_activity_section.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_stats_card.dart';
import '../widgets/profile_streak_card.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _dispatchFromAuthBloc();
  }

  void _dispatchFromAuthBloc() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      _currentUserId = authState.user.userId;
      context.read<ProfileBloc>().add(LoadProfile(userId: _currentUserId!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, authState) {
        if (authState is Unauthenticated) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const AuthPage()),
            (route) => false,
          );
        }
      },
      child: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message, style: GoogleFonts.poppins()),
                backgroundColor: Colors.red.shade400,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.all(16),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading || state is ProfileInitial) {
            return Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2,
              ),
            );
          }
          if (state is ProfileLoaded) return _buildContent(context, state);
          return _buildErrorState(context);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, ProfileLoaded state) {
    final user = state.user;
    final streak = state.streak;
    final achievements = state.achievements;
    final userAchievements = state.userAchievements;
    final friends = state.friends;

    final unlockedIds = userAchievements.map((ua) => ua.achievementId).toSet();
    final achievementMaps = achievements
        .map(
          (a) => {
            'id': a.id,
            'title': a.name,
            'desc': a.description ?? '',
            'badgeAsset': _resolveBadgeAsset(a.badgeIcon),
            'color': _resolveColor(a.conditionType),
            'unlocked': unlockedIds.contains(a.id),
          },
        )
        .toList();

    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            children: [
              ProfileHeader(
                name: user.name,
                email: user.email,
                joinYear: user.joinedAt.year,
                onEditPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SettingsPage()),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    ProfileStatsCard(
                      totalFriends: friends.length,
                      totalActivities: userAchievements.length,
                      currentStreak: streak.currentStreak,
                    ),
                    const SizedBox(height: 16),
                    ProfileStreakCard(
                      currentStreak: streak.currentStreak,
                      longestStreak: streak.longestStreak,
                    ),
                    const SizedBox(height: 20),
                    ProfileAchievementSection(
                      achievements: achievementMaps,
                      onSeeAll: () {},
                    ),
                    const SizedBox(height: 20),
                    ProfileActivitySection(
                      activities: const [],
                      onCreatePost: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '📝 Fitur buat post coming soon!',
                              style: GoogleFonts.poppins(),
                            ),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.black87,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: const EdgeInsets.all(16),
                          ),
                        );
                      },
                      onSeeAll: () {},
                    ),
                    const SizedBox(height: 24),
                    _buildAppVersion(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ── Settings icon kanan atas ─────────────────────────────────────────
        Positioned(
          top: 52,
          right: 16,
          child: _SettingsIconButton(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SettingsPage()),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('😕', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text(
            'Gagal memuat profil',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),
          if (_currentUserId != null)
            ElevatedButton(
              onPressed: () => context.read<ProfileBloc>().add(
                LoadProfile(userId: _currentUserId!),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Coba lagi',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  String _resolveBadgeAsset(String? badgeIcon) {
    final fileName = (badgeIcon == null || badgeIcon.trim().isEmpty)
        ? 'well_organized.png'
        : badgeIcon.trim();

    // Data backup.sql memakai first_focus.png, asset project saat ini bernama
    // firts_focus.png.
    final normalizedName = fileName == 'first_focus.png'
        ? 'firts_focus.png'
        : fileName;

    return 'lib/assets/badge/$normalizedName';
  }

  Color _resolveColor(String? t) {
    if (t == null) return const Color(0xFFB79CED);
    if (t.contains('study') || t.contains('focus')) {
      return const Color(0xFF4D96FF);
    }
    if (t.contains('streak')) return const Color(0xFFFF8C42);
    if (t.contains('task')) return const Color(0xFF6BCB77);
    if (t.contains('friend') || t.contains('activity') || t.contains('like')) {
      return const Color(0xFFFF6B9D);
    }
    if (t.contains('scanner') || t.contains('ocr') || t.contains('tools')) {
      return const Color(0xFF38BDF8);
    }
    return const Color(0xFFB79CED);
  }

  Widget _buildAppVersion() {
    return Column(
      children: [
        Text(
          '🎓 Ploopy',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Versi 1.0.0',
          style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey.shade400),
        ),
      ],
    );
  }
}

class _SettingsIconButton extends StatelessWidget {
  final VoidCallback onTap;
  const _SettingsIconButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(Icons.settings_rounded, size: 20, color: AppColors.primary),
      ),
    );
  }
}
