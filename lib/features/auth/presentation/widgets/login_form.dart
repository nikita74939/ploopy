import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../controllers/auth_controller.dart';

class LoginForm extends StatelessWidget {
  final AuthController ctrl;
  final VoidCallback onNavigate;
  final VoidCallback onBiometricPressed;

  const LoginForm({
    super.key,
    required this.ctrl,
    required this.onNavigate,
    required this.onBiometricPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextField(controller: ctrl.emailCtrl, hint: 'Email'),
        const SizedBox(height: 12),
        CustomTextField(
          controller: ctrl.passCtrl,
          hint: 'Password',
          obscure: true,
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            child: Text('Lupa password?', style: AppTextStyles.link),
          ),
        ),
        const SizedBox(height: 4),
        PrimaryButton(
          label: ctrl.loading ? 'Memuat...' : 'Masuk',
          onPressed: ctrl.loading
              ? null
              : () => ctrl.login(context, onNavigate),
        ),
        if (ctrl.error != null) ...[
          const SizedBox(height: 8),
          Text(
            ctrl.error!,
            style: AppTextStyles.error,
            textAlign: TextAlign.center,
          ),
        ],
        const Spacer(),
        _buildDivider(),
        const SizedBox(height: 12),
        _buildBiometricButton(),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: AppColors.greyBorder)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('atau', style: AppTextStyles.small),
        ),
        Expanded(child: Divider(color: AppColors.greyBorder)),
      ],
    );
  }

  Widget _buildBiometricButton() {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: OutlinedButton.icon(
        onPressed: onBiometricPressed,
        icon: SvgPicture.asset(
          'assets/icons/fingerprint.svg',
          width: 20,
          height: 20,
          colorFilter: ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
        ),
        label: Text(
          'Gunakan Sidik Jari',
          style: AppTextStyles.body.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.primaryBorder),
          backgroundColor: AppColors.primaryLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}