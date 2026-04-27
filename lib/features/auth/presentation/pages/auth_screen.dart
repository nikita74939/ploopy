import 'package:flutter/material.dart';
import 'package:ploopy/features/home/presentation/pages/home_screen.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_tab_selector.dart';
import '../widgets/login_form.dart';
import '../widgets/register_form.dart';
import '../widgets/biometric_login_sheet.dart';
import '../widgets/biometric_activation_sheet.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthController(),
      child: const _AuthView(),
    );
  }
}

class _AuthView extends StatelessWidget {
  const _AuthView();

  void _navigateToHome(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  void _showBiometricLoginSheet(BuildContext context, AuthController ctrl) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => ChangeNotifierProvider.value(
        value: ctrl,
        child: Consumer<AuthController>(
          builder: (ctx, c, _) => BiometricLoginSheet(
            ctrl: c,
            onSuccess: () {
              Navigator.pop(sheetContext);
              _navigateToHome(context);
            },
          ),
        ),
      ),
    );
  }

  void _showBiometricActivationSheet(
    BuildContext context,
    AuthController ctrl,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: ChangeNotifierProvider.value(
          value: ctrl,
          child: Consumer<AuthController>(
            builder: (ctx, c, _) => BiometricActivationSheet(
              ctrl: c,
              onSuccess: () {
                Navigator.pop(sheetContext);
                _navigateToHome(context);
              },
            ),
          ),
        ),
      ),
    );
  }

  void _handleBiometricPressed(BuildContext context, AuthController ctrl) {
    ctrl.onBiometricButtonPressed(
      context,
      onSuccess: () => _navigateToHome(context),
      showActivationDialog: () =>
          _showBiometricActivationSheet(context, ctrl),
      showBiometricSheet: () => _showBiometricLoginSheet(context, ctrl),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              AuthTabSelector(
                isLoginSelected: ctrl.isLoginSelected,
                onTabChanged: (isLogin) => ctrl.setTab(isLogin),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ctrl.isLoginSelected
                    ? LoginForm(
                        ctrl: ctrl,
                        onNavigate: () => _navigateToHome(context),
                        onBiometricPressed: () =>
                            _handleBiometricPressed(context, ctrl),
                      )
                    : RegisterForm(
                        ctrl: ctrl,
                        onSuccess: () => ctrl.setTab(true),
                      ),
              ),
            ],
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
          style: AppTextStyles.heading.copyWith(
            fontSize: 24,
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Selamat datang! Kelola belajarmu dengan mudah.',
          style: AppTextStyles.subtitle,
        ),
      ],
    );
  }
}