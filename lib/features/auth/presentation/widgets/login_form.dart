import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/auth_bloc.dart';

class LoginForm extends StatefulWidget {
  final VoidCallback onNavigate;
  final VoidCallback onBiometricPressed;
  final VoidCallback onSwitchToRegister;
  final bool showBiometricLogin;

  const LoginForm({
    super.key,
    required this.onNavigate,
    required this.onBiometricPressed,
    required this.onSwitchToRegister,
    required this.showBiometricLogin,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _submit(BuildContext formContext) {
    if (Form.maybeOf(formContext)?.validate() == true) {
      context.read<AuthBloc>().add(
        LoginRequested(email: _emailCtrl.text.trim(), password: _passCtrl.text),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Builder(
        builder: (formContext) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _AuthTextField(
              controller: _emailCtrl,
              hint: 'Email',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Masukkan email kamu';
                if (!v.contains('@')) return 'Email tidak valid';
                return null;
              },
            ),
            const SizedBox(height: 12),
            _AuthTextField(
              controller: _passCtrl,
              hint: 'Password',
              prefixIcon: Icons.lock_outline,
              obscure: true,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Masukkan password kamu';
                return null;
              },
            ),
            const SizedBox(height: 16),
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                return _PrimaryButton(
                  label: state is AuthLoading ? 'Memuat...' : 'Masuk',
                  onPressed: state is AuthLoading
                      ? null
                      : () => _submit(formContext),
                );
              },
            ),
            if (widget.showBiometricLogin) ...[
              const SizedBox(height: 22),
              _buildDivider(),
              const SizedBox(height: 12),
              _buildBiometricButton(),
            ],
            const SizedBox(height: 16),
            _buildRegisterRedirect(),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.greyHandle)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('atau', style: AppTextStyles.bodySmall),
        ),
        const Expanded(child: Divider(color: AppColors.greyHandle)),
      ],
    );
  }

  Widget _buildBiometricButton() {
    return SizedBox(
      height: 44,
      child: OutlinedButton.icon(
        onPressed: widget.onBiometricPressed,
        icon: Icon(
          Icons.fingerprint_rounded,
          color: AppColors.primary,
          size: 22,
        ),
        label: Text('Gunakan Sidik Jari', style: AppTextStyles.buttonSecondary),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.primary.withValues(alpha: 0.4)),
          backgroundColor: AppColors.primary.withValues(alpha: 0.06),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterRedirect() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Belum punya akun? ', style: AppTextStyles.bodySmall),
        GestureDetector(
          onTap: widget.onSwitchToRegister,
          child: Text('Daftar', style: AppTextStyles.link),
        ),
      ],
    );
  }
}

// ─── Shared form widgets ──────────────────────────────────────────────────────

class _AuthTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData? prefixIcon;
  final TextInputType? keyboardType;
  final bool obscure;
  final String? Function(String?)? validator;

  const _AuthTextField({
    required this.controller,
    required this.hint,
    this.prefixIcon,
    this.keyboardType,
    this.obscure = false,
    this.validator,
  });

  @override
  State<_AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<_AuthTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      obscureText: widget.obscure ? _obscureText : false,
      style: AppTextStyles.body,
      validator: widget.validator,
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: AppTextStyles.hint,
        prefixIcon: widget.prefixIcon != null
            ? Icon(widget.prefixIcon, color: AppColors.greyHint, size: 20)
            : null,
        suffixIcon: widget.obscure
            ? GestureDetector(
                onTap: () => setState(() => _obscureText = !_obscureText),
                child: Icon(
                  _obscureText
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.greyHint,
                  size: 20,
                ),
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.greyBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.greyBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const _PrimaryButton({required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Text(label, style: AppTextStyles.buttonPrimary),
      ),
    );
  }
}
