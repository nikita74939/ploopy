import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../controllers/auth_controller.dart';

class BiometricLoginSheet extends StatelessWidget {
  final AuthController ctrl;
  final VoidCallback onSuccess;

  const BiometricLoginSheet({
    super.key,
    required this.ctrl,
    required this.onSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(),
          const SizedBox(height: 20),
          _buildIcon(),
          const SizedBox(height: 20),
          Text('Login dengan Biometric', style: AppTextStyles.heading),
          const SizedBox(height: 8),
          Text(
            'Gunakan sidik jari untuk masuk dengan cepat dan aman',
            style: AppTextStyles.subtitle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: ctrl.loading ? 'Memproses...' : 'Gunakan Sidik Jari',
            onPressed: ctrl.loading
                ? null
                : () => ctrl.loginWithBiometric(context, onSuccess),
          ),
          if (ctrl.error != null) ...[
            const SizedBox(height: 8),
            Text(
              ctrl.error!,
              style: AppTextStyles.error,
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: AppTextStyles.body.copyWith(color: AppColors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.greyHandle,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        shape: BoxShape.circle,
      ),
      child: SvgPicture.asset(
        'assets/icons/fingerprint.svg',
        width: 48,
        height: 48,
        colorFilter: ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
      ),
    );
  }
}