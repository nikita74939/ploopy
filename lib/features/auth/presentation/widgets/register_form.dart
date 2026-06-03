import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/auth_bloc.dart';

class RegisterForm extends StatefulWidget {
  /// Dipanggil setelah state [Authenticated] — untuk UI feedback tambahan
  /// (mis. switch tab). Navigasi ke home ditangani oleh AuthPage BlocListener.
  final VoidCallback onSuccess;
  final VoidCallback onSwitchToLogin;

  const RegisterForm({
    super.key,
    required this.onSuccess,
    required this.onSwitchToLogin,
  });

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        RegisterRequested(
          name: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          // AuthPage BlocListener menangani navigasi ke home.
          // Di sini hanya trigger callback untuk UI feedback (snackbar, tab switch).
          widget.onSuccess();
        }
        // AuthError ditangani oleh AuthPage BlocListener (snackbar global)
      },
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _AuthTextField(
                controller: _nameCtrl,
                hint: 'Nama Lengkap',
                prefixIcon: Icons.person_outline,
                keyboardType: TextInputType.name,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Masukkan nama kamu';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
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
                hint: 'Password (min. 6 karakter)',
                prefixIcon: Icons.lock_outline,
                obscure: true,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Masukkan password';
                  if (v.length < 6) return 'Password minimal 6 karakter';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _AuthTextField(
                controller: _confirmPassCtrl,
                hint: 'Konfirmasi Password',
                prefixIcon: Icons.lock_outline,
                obscure: true,
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Konfirmasi password kamu';
                  }
                  if (v != _passCtrl.text) return 'Password tidak cocok';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  return _PrimaryButton(
                    label: state is AuthLoading ? 'Memuat...' : 'Daftar',
                    onPressed: state is AuthLoading ? null : _submit,
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildTermsText(),
              const SizedBox(height: 16),
              _buildLoginRedirect(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTermsText() {
    return Text.rich(
      TextSpan(
        style: AppTextStyles.small,
        children: [
          const TextSpan(text: 'Dengan mendaftar, kamu menyetujui '),
          TextSpan(text: 'Syarat & Ketentuan', style: AppTextStyles.link),
          const TextSpan(text: ' serta '),
          TextSpan(text: 'Kebijakan Privasi', style: AppTextStyles.link),
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
        Text('Sudah punya akun? ', style: AppTextStyles.bodySmall),
        GestureDetector(
          onTap: widget.onSwitchToLogin,
          child: Text('Masuk', style: AppTextStyles.link),
        ),
      ],
    );
  }
}

// ─── Shared field & button ────────────────────────────────────────────────────

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
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.greyBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.greyBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
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
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(label, style: AppTextStyles.buttonPrimary),
      ),
    );
  }
}
