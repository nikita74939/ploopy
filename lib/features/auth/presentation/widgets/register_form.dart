import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../controllers/auth_controller.dart';

class RegisterForm extends StatelessWidget {
  final AuthController ctrl;
  final VoidCallback onSuccess;

  const RegisterForm({super.key, required this.ctrl, required this.onSuccess});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomTextField(
            controller: ctrl.regNameCtrl,
            hint: 'Nama Lengkap',
            keyboardType: TextInputType.name,
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: ctrl.regEmailCtrl,
            hint: 'Email',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: ctrl.regPassCtrl,
            hint: 'Password (min. 6 karakter)',
            obscure: true,
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: ctrl.regConfirmPassCtrl,
            hint: 'Konfirmasi Password',
            obscure: true,
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            label: ctrl.loading ? 'Memuat...' : 'Daftar',
            onPressed:
                ctrl.loading
                    ? null
                    : () => ctrl.register(context, () {
                      _showSuccessSnackbar(context);
                      onSuccess();
                    }),
          ),
          if (ctrl.error != null) ...[
            const SizedBox(height: 12),
            _buildErrorMessage(ctrl.error!),
          ],
          const SizedBox(height: 20),
          _buildTermsText(),
          const SizedBox(height: 16),
          _buildLoginRedirect(),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.error.withOpacity(0.3), width: 0.5),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: AppColors.error, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: AppTextStyles.error)),
        ],
      ),
    );
  }

  Widget _buildTermsText() {
    return Text.rich(
      TextSpan(
        style: AppTextStyles.caption,
        children: [
          const TextSpan(text: 'Dengan mendaftar, kamu menyetujui '),
          TextSpan(
            text: 'Syarat & Ketentuan',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const TextSpan(text: ' serta '),
          TextSpan(
            text: 'Kebijakan Privasi',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const TextSpan(text: ' kami.'),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildLoginRedirect() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Sudah punya akun? ', style: AppTextStyles.small),
        GestureDetector(
          onTap: () => ctrl.setTab(true),
          child: Text(
            'Masuk',
            style: AppTextStyles.small.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  void _showSuccessSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Registrasi berhasil! Silakan login.',
                style: AppTextStyles.body.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
