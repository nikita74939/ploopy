import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/auth_tab_selector.dart';
import '../widgets/biometric_activation_sheet.dart';
import '../widgets/biometric_login_sheet.dart';
import '../widgets/login_form.dart';
import '../widgets/register_form.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _isLoginSelected = true;

  void _setTab(bool isLogin) {
    setState(() => _isLoginSelected = isLogin);
  }

  void _navigateToHome() {
    Navigator.pushReplacementNamed(context, AppRoutes.home);
  }

  void _showBiometricLoginSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.transparent,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: context.read<AuthBloc>(),
        child: const BiometricLoginSheet(),
      ),
    );
  }

  void _showBiometricActivationSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetCtx).viewInsets.bottom,
        ),
        child: BlocProvider.value(
          value: context.read<AuthBloc>(),
          child: const BiometricActivationSheet(),
        ),
      ),
    );
  }

  void _handleBiometricPressed() {
    final bloc = context.read<AuthBloc>();
    bloc.repository.getCurrentUser().then((user) {
      if (!mounted) return;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Login dengan email & password terlebih dahulu untuk mengaktifkan sidik jari.',
            ),
          ),
        );
        return;
      }

      if (user.biometricEnabled) {
        _showBiometricLoginSheet();
      } else {
        _showBiometricActivationSheet();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated || state is BiometricEnabled) {
          _navigateToHome();
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: AppColors.onPrimary,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(state.message)),
                ],
              ),
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
      child: Scaffold(
        backgroundColor: AppColors.greyLight,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                AuthTabSelector(
                  isLoginSelected: _isLoginSelected,
                  onTabChanged: _setTab,
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: _isLoginSelected
                      ? LoginForm(
                          onNavigate: _navigateToHome,
                          onBiometricPressed: _handleBiometricPressed,
                          onSwitchToRegister: () => _setTab(false),
                        )
                      : RegisterForm(
                          onSuccess: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      color: AppColors.onPrimary,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Registrasi berhasil!',
                                        style: AppTextStyles.body.copyWith(
                                          color: AppColors.onPrimary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                backgroundColor: AppColors.success,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                margin: const EdgeInsets.all(16),
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          },
                          onSwitchToLogin: () => _setTab(true),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ploopy',
          style: AppTextStyles.display.copyWith(
            fontSize: 22,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Selamat datang! Kelola belajarmu dengan mudah.',
          style: AppTextStyles.bodySmall.copyWith(height: 1.4),
        ),
      ],
    );
  }
}
