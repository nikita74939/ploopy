import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/bottom_sheet_insets.dart';
import '../bloc/auth_bloc.dart';

/// Sheet untuk mengaktifkan biometrik pertama kali.
/// Dipanggil saat user sudah login (ada di AuthPage setelah tap tombol sidik jari
/// dan belum punya biometric terdaftar).
///
/// Flow:
/// 1. User menekan "Aktifkan Sidik Jari"
/// 2. Bloc dispatch [EnableBiometricRequested]
/// 3. Repository verifikasi sidik jari OS → set biometricEnabled = true
/// 4. State [BiometricEnabled] → tutup sheet & panggil onSuccess
class BiometricActivationSheet extends StatelessWidget {
  final VoidCallback? onSkipped;

  const BiometricActivationSheet({super.key, this.onSkipped});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is BiometricEnabled) {
          Navigator.pop(context);
        } else if (state is AuthError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Container(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          BottomSheetInsets.bottom(context, spacing: 24),
        ),
        decoration: const BoxDecoration(
          color: AppColors.surface,
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
            const SizedBox(height: 6),
            Text(
              'Gunakan sidik jari perangkat kamu untuk login lebih cepat dan aman.',
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                return _PrimaryButton(
                  label: state is AuthLoading
                      ? 'Memproses...'
                      : 'Aktifkan Sidik Jari',
                  onPressed: state is AuthLoading
                      ? null
                      : () => context.read<AuthBloc>().add(
                          EnableBiometricRequested(),
                        ),
                );
              },
            ),
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is AuthError) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      state.message,
                      style: AppTextStyles.error,
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onSkipped?.call();
              },
              child: Text('Lewati', style: AppTextStyles.bodySmall),
            ),
          ],
        ),
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
        color: AppColors.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.fingerprint_rounded,
        size: 48,
        color: AppColors.primary,
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
