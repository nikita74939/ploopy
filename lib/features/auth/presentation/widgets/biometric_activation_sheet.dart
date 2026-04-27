import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../controllers/auth_controller.dart';

class BiometricActivationSheet extends StatelessWidget {
  final AuthController ctrl;
  final VoidCallback onSuccess;

  const BiometricActivationSheet({
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(child: _buildHandle()),
          const SizedBox(height: 20),
          Center(child: _buildIcon()),
          const SizedBox(height: 20),
          Text(
            'Aktifkan Sidik Jari',
            style: AppTextStyles.heading,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Masukkan email & password untuk mendaftarkan sidik jari kamu',
            style: AppTextStyles.subtitle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          CustomTextField(
            controller: ctrl.bioEmailCtrl,
            hint: 'Email',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: ctrl.bioPassCtrl,
            hint: 'Password',
            obscure: true,
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: ctrl.loading ? 'Memproses...' : 'Daftarkan Sidik Jari',
            onPressed: ctrl.loading
                ? null
                : () => ctrl.activateBiometricWithCredentials(
                      context,
                      onSuccess,
                    ),
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