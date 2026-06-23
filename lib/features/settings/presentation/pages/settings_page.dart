import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _biometricEnabled = false;

  @override
  void initState() {
    super.initState();
    final state = context.read<AuthBloc>().state;
    if (state is Authenticated) {
      _biometricEnabled = state.user.biometricEnabled;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.auth,
            (route) => false,
          );
        } else if (state is Authenticated) {
          setState(() => _biometricEnabled = state.user.biometricEnabled);
        } else if (state is BiometricPreferenceUpdated) {
          setState(() => _biometricEnabled = state.user.biometricEnabled);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.user.biometricEnabled
                    ? 'Login biometrik aktif.'
                    : 'Login biometrik dinonaktifkan.',
              ),
            ),
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          title: Text('Settings', style: AppTextStyles.title),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              _SettingsCard(
                children: [
                  _SwitchRow(
                    icon: Icons.notifications_rounded,
                    title: 'Notifikasi',
                    subtitle: 'Pengingat dan update aplikasi',
                    value: _notificationsEnabled,
                    onChanged: (value) =>
                        setState(() => _notificationsEnabled = value),
                  ),
                  const Divider(
                    height: 1,
                    color: AppColors.greyBorder,
                    indent: 58,
                  ),
                  _SwitchRow(
                    icon: Icons.fingerprint_rounded,
                    title: 'Aktifkan Login Biometrik',
                    subtitle: _biometricEnabled
                        ? 'Aktif untuk fingerprint atau face unlock'
                        : 'Login biasa dulu, lalu aktifkan dari sini',
                    value: _biometricEnabled,
                    enabled: state is! AuthLoading,
                    onChanged: (value) {
                      context.read<AuthBloc>().add(
                        SetBiometricEnabledRequested(enabled: value),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _SettingsCard(
                children: [
                  _MenuRow(
                    icon: Icons.rate_review_rounded,
                    title: 'Kesan dan Pesan',
                    subtitle: 'Teknologi Pemrograman Mobile',
                    onTap: _showCourseReflection,
                  ),
                  const Divider(
                    height: 1,
                    color: AppColors.greyBorder,
                    indent: 58,
                  ),
                  _MenuRow(
                    icon: Icons.info_outline_rounded,
                    title: 'Tentang Ploopy',
                    subtitle: 'Versi 1.0.0',
                    onTap: () {},
                  ),
                  const Divider(
                    height: 1,
                    color: AppColors.greyBorder,
                    indent: 58,
                  ),
                  _MenuRow(
                    icon: Icons.logout_rounded,
                    title: 'Logout',
                    subtitle: 'Keluar dari akun saat ini',
                    color: AppColors.error,
                    onTap: _showLogoutDialog,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCourseReflection() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.transparent,
      isScrollControlled: true,
      builder: (context) => const _CourseReflectionSheet(),
    );
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
}

class _CourseReflectionSheet extends StatelessWidget {
  const _CourseReflectionSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.greyBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.greyBorder,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                const _IconBubble(icon: Icons.rate_review_rounded),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Kesan dan Pesan', style: AppTextStyles.title),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Mata Kuliah Teknologi Pemrograman Mobile',
              style: AppTextStyles.caption,
            ),
            const SizedBox(height: 18),
            _ReflectionBlock(
              title: 'Kesan',
              body:
                  'Mata kuliah ini memberikan pengalaman yang menarik karena kami belajar membangun aplikasi mobile secara langsung dari proses perancangan, implementasi fitur, integrasi data, sampai pengujian aplikasi.',
            ),
            const SizedBox(height: 12),
            _ReflectionBlock(
              title: 'Pesan',
              body:
                  'Semoga mata kuliah ini terus dikembangkan dengan lebih banyak praktik, studi kasus nyata, dan pembahasan best practice agar mahasiswa semakin siap membuat aplikasi mobile yang bermanfaat.',
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReflectionBlock extends StatelessWidget {
  final String title;
  final String body;

  const _ReflectionBlock({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.greyBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(body, style: AppTextStyles.bodySmall.copyWith(height: 1.45)),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

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
      child: Column(children: children),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _SwitchRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    this.enabled = true,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          _IconBubble(icon: icon),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTextStyles.caption),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeThumbColor: AppColors.primary,
            onChanged: enabled ? onChanged : null,
          ),
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color? color;
  final VoidCallback onTap;

  const _MenuRow({
    required this.icon,
    required this.title,
    required this.subtitle,
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            _IconBubble(icon: icon, color: effectiveColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.body.copyWith(
                      color: color ?? AppColors.textMain,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTextStyles.caption),
                ],
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

class _IconBubble extends StatelessWidget {
  final IconData icon;
  final Color? color;

  const _IconBubble({required this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.primary;
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: effectiveColor.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 18, color: effectiveColor),
    );
  }
}
