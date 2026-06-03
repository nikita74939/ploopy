import 'package:flutter/material.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/ploopy_mascot.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _navigateToLogin();
  }

  Future<void> _navigateToLogin() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.auth);
    }
  }

  void _goToAuth() {
    Navigator.pushReplacementNamed(context, AppRoutes.auth);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 36),
          child: Column(
            children: [
              const Spacer(),
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  const PloopyMascot(size: 210),
                  Positioned(
                    left: -12,
                    top: 20,
                    child: _Sparkle(size: 18, color: AppColors.primary),
                  ),
                  Positioned(
                    right: 6,
                    top: -8,
                    child: _Sparkle(size: 14, color: AppColors.warning),
                  ),
                  Positioned(
                    right: -14,
                    bottom: 44,
                    child: _Sparkle(size: 18, color: AppColors.primaryBorder),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'ploopy',
                style: AppTextStyles.display.copyWith(
                  fontSize: 46,
                  height: 0.95,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Your study buddy, every day!',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textMain,
                  height: 1.45,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _goToAuth,
                  child: const Text('Login'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: _goToAuth,
                  child: const Text('Register'),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Study better, together',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Sparkle extends StatelessWidget {
  final double size;
  final Color color;

  const _Sparkle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.auto_awesome_rounded, size: size, color: color);
  }
}
