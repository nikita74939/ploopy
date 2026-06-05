import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../activity/domain/entities/activity_entity.dart';
import '../../../activity/presentation/bloc/activity_bloc.dart';
import '../../../activity/presentation/widgets/activity_composer_sheet.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../bloc/profile_bloc.dart';
import 'edit_profile_page.dart';
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
      context.read<ActivityBloc>().add(
        LoadActivitiesByUser(userId: _currentUserId!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, authState) {
        if (authState is Unauthenticated) {
          if (ModalRoute.of(context)?.isCurrent != true) return;
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.auth,
            (route) => false,
          );
        }
      },
      child: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message, style: AppTextStyles.body),
                backgroundColor: AppColors.error,
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
            'desc': a.description,
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
                bio: user.bio,
                avatarUrl: user.avatarUrl,
                joinYear: user.joinedAt.year,
                onEditPressed: () => _openEditProfile(user),
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
                    _ProfileSimpleMenu(
                      onEditProfile: () => _openEditProfile(user),
                      onSettings: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsPage()),
                      ),
                      onLogout: _showLogoutDialog,
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
                    BlocBuilder<ActivityBloc, ActivityState>(
                      builder: (context, activityState) {
                        final activities = activityState is ActivitiesLoaded
                            ? activityState.activities
                            : <ActivityEntity>[];
                        return ProfileActivitySection(
                          activities: activities.map(_activityToPost).toList(),
                          onCreatePost: _showActivityComposer,
                          onSeeAll: () =>
                              Navigator.pushNamed(context, AppRoutes.social),
                        );
                      },
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
              MaterialPageRoute(builder: (_) => const SettingsPage()),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openEditProfile(UserEntity user) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => EditProfilePage(user: user)),
    );
    if (!mounted || saved != true || _currentUserId == null) return;
    context.read<ProfileBloc>().add(LoadProfile(userId: _currentUserId!));
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Logout', style: AppTextStyles.title),
        content: Text(
          'Apakah kamu yakin ingin keluar dari akun ini?',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Batal', style: AppTextStyles.buttonSecondary),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthBloc>().add(LogoutRequested());
            },
            child: Text(
              'Logout',
              style: AppTextStyles.body.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sentiment_dissatisfied_rounded,
            size: 40,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 12),
          Text('Gagal memuat profil', style: AppTextStyles.bodySmall),
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
              child: Text('Coba lagi', style: AppTextStyles.buttonPrimary),
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
    if (t == null) return AppColors.purpleAccent;
    if (t.contains('study') || t.contains('focus')) {
      return AppColors.blueAccent;
    }
    if (t.contains('streak')) return AppColors.primary;
    if (t.contains('task')) return AppColors.success;
    if (t.contains('friend') || t.contains('activity') || t.contains('like')) {
      return AppColors.pinkAccent;
    }
    if (t.contains('scanner') || t.contains('ocr') || t.contains('tools')) {
      return AppColors.tealAccent;
    }
    return AppColors.purpleAccent;
  }

  Future<void> _showActivityComposer() async {
    final userId = _currentUserId;
    if (userId == null) return;
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<ActivityBloc>(),
        child: ActivityComposerSheet(userId: userId),
      ),
    );
    if (!mounted) return;
    context.read<ActivityBloc>().add(LoadActivitiesByUser(userId: userId));
  }

  Map<String, dynamic> _activityToPost(ActivityEntity activity) {
    return {
      'authorName': activity.userName ?? 'Kamu',
      'authorAvatar': activity.userName ?? 'K',
      'authorColor': AppColors.primary,
      'date': DateTime.now().difference(activity.createdAt).inDays == 0
          ? 'Hari ini'
          : '${DateTime.now().difference(activity.createdAt).inDays}h',
      'fullDate': activity.createdAt.toString(),
      'achievements': const [],
      'images': activity.imageUrls,
      'info': activity.location == null ? const [] : [activity.location],
      'content': activity.text,
    };
  }

  Widget _buildAppVersion() {
    return Column(
      children: [
        Text(
          'Ploopy',
          style: AppTextStyles.body.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Versi 1.0.0',
          style: AppTextStyles.caption.copyWith(fontSize: 10),
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
          color: AppColors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.08),
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

class _ProfileSimpleMenu extends StatelessWidget {
  final VoidCallback onEditProfile;
  final VoidCallback onSettings;
  final VoidCallback onLogout;

  const _ProfileSimpleMenu({
    required this.onEditProfile,
    required this.onSettings,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.greyBorder),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _ProfileSimpleMenuItem(
            icon: Icons.edit_outlined,
            title: 'Edit Profil',
            onTap: onEditProfile,
          ),
          const Divider(height: 1, color: AppColors.greyBorder, indent: 58),
          _ProfileSimpleMenuItem(
            icon: Icons.settings_outlined,
            title: 'Settings',
            onTap: onSettings,
          ),
          const Divider(height: 1, color: AppColors.greyBorder, indent: 58),
          _ProfileSimpleMenuItem(
            icon: Icons.logout_rounded,
            title: 'Logout',
            color: AppColors.error,
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}

class _ProfileSimpleMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? color;
  final VoidCallback onTap;

  const _ProfileSimpleMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.textSecondary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: effectiveColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 17, color: effectiveColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color ?? AppColors.textMain,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: color ?? AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
