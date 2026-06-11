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
  bool _isBiometricActivationSheetOpen = false;
  bool _isBiometricLoginSheetOpen = false;
  bool _hasBiometricLogin = false;
  bool _isNavigatingToHome = false;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthInitial) {
      context.read<AuthBloc>().add(CheckAuthStatus());
    } else if (authState is Authenticated) {
      _navigateToHome();
    }
    _refreshBiometricAvailability();
  }

  void _setTab(bool isLogin) {
    setState(() => _isLoginSelected = isLogin);
  }

  void _navigateToHome() {
    if (_isNavigatingToHome) return;
    _isNavigatingToHome = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.home,
        (route) => false,
      );
    });
  }

  Future<void> _refreshBiometricAvailability() async {
    final available = await context
        .read<AuthBloc>()
        .repository
        .hasBiometricLogin();
    if (!mounted) return;
    setState(() => _hasBiometricLogin = available);
  }

  Future<void> _showBiometricLoginSheet() async {
    if (_isBiometricLoginSheetOpen) return;
    _isBiometricLoginSheetOpen = true;

    final authenticated = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.transparent,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: context.read<AuthBloc>(),
        child: const BiometricLoginSheet(),
      ),
    );
    _isBiometricLoginSheetOpen = false;

    if (!mounted) return;
    if (authenticated == true) {
      _navigateToHome();
    }
  }

  void _showBiometricActivationSheet({VoidCallback? onSkipped}) {
    if (_isBiometricActivationSheetOpen) return;
    _isBiometricActivationSheetOpen = true;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.transparent,
      isDismissible: onSkipped == null,
      enableDrag: onSkipped == null,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: context.read<AuthBloc>(),
        child: BiometricActivationSheet(onSkipped: onSkipped),
      ),
    ).whenComplete(() {
      _isBiometricActivationSheetOpen = false;
    });
  }

  void _handleBiometricPressed() {
    if (!_hasBiometricLogin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Login dengan email & password terlebih dahulu untuk mengaktifkan biometrik.',
          ),
        ),
      );
      return;
    }
    _showBiometricLoginSheet();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          _refreshBiometricAvailability();
          if (_isBiometricLoginSheetOpen) return;
          _navigateToHome();
        } else if (state is BiometricEnabled) {
          _refreshBiometricAvailability();
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
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom -
                    46,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 22),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: AppColors.greyBorder),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 24,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        AuthTabSelector(
                          isLoginSelected: _isLoginSelected,
                          onTabChanged: _setTab,
                        ),
                        const SizedBox(height: 18),
                        _isLoginSelected
                            ? LoginForm(
                                onNavigate: _navigateToHome,
                                onBiometricPressed: _handleBiometricPressed,
                                onSwitchToRegister: () => _setTab(false),
                                showBiometricLogin: _hasBiometricLogin,
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
                                              style: AppTextStyles.body
                                                  .copyWith(
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Study better, together',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 60),
        Text(
          _isLoginSelected ? "Let's login to" : "Let's join",
          textAlign: TextAlign.center,
          style: AppTextStyles.title.copyWith(fontSize: 18),
        ),
        Text(
          'Ploopy',
          textAlign: TextAlign.center,
          style: AppTextStyles.display.copyWith(
            fontSize: 30,
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
