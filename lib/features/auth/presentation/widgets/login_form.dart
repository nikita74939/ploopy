import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/auth_bloc.dart';

class LoginForm extends StatefulWidget {
  final VoidCallback onNavigate;
  final VoidCallback onBiometricPressed;
  final VoidCallback onForgotPassword;
  final VoidCallback onSwitchToRegister;

  const LoginForm({
    super.key,
    required this.onNavigate,
    required this.onBiometricPressed,
    required this.onForgotPassword,
    required this.onSwitchToRegister,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            LoginRequested(
              email: _emailCtrl.text.trim(),
              password: _passCtrl.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
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
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: widget.onForgotPassword,
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              ),
              child: Text(
                'Lupa password?',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              return _PrimaryButton(
                label: state is AuthLoading ? 'Memuat...' : 'Masuk',
                onPressed: state is AuthLoading ? null : _submit,
              );
            },
          ),
          const Spacer(),
          _buildDivider(),
          const SizedBox(height: 12),
          _buildBiometricButton(),
          const SizedBox(height: 16),
          _buildRegisterRedirect(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey.shade300)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'atau',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey.shade300)),
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
        label: Text(
          'Gunakan Sidik Jari',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.primary.withOpacity(0.4)),
          backgroundColor: AppColors.primary.withOpacity(0.06),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  Widget _buildRegisterRedirect() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Belum punya akun? ',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
        GestureDetector(
          onTap: widget.onSwitchToRegister,
          child: Text(
            'Daftar',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
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
      style: const TextStyle(fontSize: 15, color: Color(0xFF1A1A2E)),
      validator: widget.validator,
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
        prefixIcon: widget.prefixIcon != null
            ? Icon(widget.prefixIcon, color: Colors.grey.shade400, size: 20)
            : null,
        suffixIcon: widget.obscure
            ? GestureDetector(
                onTap: () =>
                    setState(() => _obscureText = !_obscureText),
                child: Icon(
                  _obscureText
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
              )
            : null,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.red.shade400),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
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
          disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(
          label,
          style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white),
        ),
      ),
    );
  }
}