import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:ploopy/shared/services/auth_service.dart';

class AuthController extends ChangeNotifier {
  // Login controllers
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  // Register controllers ⭐ NEW
  final regNameCtrl = TextEditingController();
  final regEmailCtrl = TextEditingController();
  final regPassCtrl = TextEditingController();
  final regConfirmPassCtrl = TextEditingController();

  // Biometric activation controllers
  final bioEmailCtrl = TextEditingController();
  final bioPassCtrl = TextEditingController();

  final _localAuth = LocalAuthentication();

  bool loading = false;
  String? error;
  String? successMessage; // ⭐ NEW untuk notif register sukses
  bool isLoginSelected = true;

  void setTab(bool loginSelected) {
    isLoginSelected = loginSelected;
    error = null;
    successMessage = null;
    notifyListeners();
  }

  // ============= LOGIN =============
  Future<void> login(BuildContext context, VoidCallback onSuccess) async {
    loading = true;
    error = null;
    notifyListeners();

    final result = await AuthService.login(
      email: emailCtrl.text.trim(),
      password: passCtrl.text,
    );

    loading = false;

    if (result['status'] == 200) {
      onSuccess();
    } else {
      error = result['data']['message'] ?? 'Login gagal';
    }
    notifyListeners();
  }

  // ============= REGISTER ⭐ NEW =============
  Future<void> register(BuildContext context, VoidCallback onSuccess) async {
    final name = regNameCtrl.text.trim();
    final email = regEmailCtrl.text.trim();
    final password = regPassCtrl.text;
    final confirmPass = regConfirmPassCtrl.text;

    // Validasi
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      error = 'Semua field wajib diisi';
      notifyListeners();
      return;
    }

    if (!_isValidEmail(email)) {
      error = 'Format email tidak valid';
      notifyListeners();
      return;
    }

    if (password.length < 6) {
      error = 'Password minimal 6 karakter';
      notifyListeners();
      return;
    }

    if (password != confirmPass) {
      error = 'Password tidak cocok';
      notifyListeners();
      return;
    }

    loading = true;
    error = null;
    successMessage = null;
    notifyListeners();

    final result = await AuthService.register(
      name: name,
      email: email,
      password: password,
    );

    loading = false;

    if (result['status'] == 200 || result['status'] == 201) {
      successMessage = 'Registrasi berhasil! Silakan login.';
      _clearRegisterForm();
      notifyListeners();
      onSuccess();
    } else {
      error = result['data']['message'] ?? 'Registrasi gagal';
      notifyListeners();
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _clearRegisterForm() {
    regNameCtrl.clear();
    regEmailCtrl.clear();
    regPassCtrl.clear();
    regConfirmPassCtrl.clear();
  }

  // ============= BIOMETRIC =============
  Future<void> onBiometricButtonPressed(
    BuildContext context, {
    required VoidCallback onSuccess,
    required VoidCallback showActivationDialog,
    required VoidCallback showBiometricSheet,
  }) async {
    final hasToken = await AuthService.hasBiometricToken();
    if (!hasToken) {
      showActivationDialog();
    } else {
      showBiometricSheet();
    }
  }

  Future<void> activateBiometricWithCredentials(
    BuildContext context,
    VoidCallback onSuccess,
  ) async {
    final email = bioEmailCtrl.text.trim();
    final password = bioPassCtrl.text;

    if (email.isEmpty || password.isEmpty) {
      error = 'Email dan password wajib diisi';
      notifyListeners();
      return;
    }

    loading = true;
    error = null;
    notifyListeners();

    final loginResult =
        await AuthService.login(email: email, password: password);
    if (loginResult['status'] != 200) {
      loading = false;
      error = loginResult['data']['message'] ?? 'Login gagal';
      notifyListeners();
      return;
    }

    final canCheck = await _localAuth.canCheckBiometrics;
    if (!canCheck) {
      loading = false;
      error = 'Perangkat tidak mendukung biometric';
      notifyListeners();
      return;
    }

    bool authenticated = false;
    try {
      authenticated = await _localAuth.authenticate(
        localizedReason: 'Daftarkan sidik jari kamu',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      loading = false;
      error = 'Biometric error: $e';
      notifyListeners();
      return;
    }

    if (!authenticated) {
      loading = false;
      notifyListeners();
      return;
    }

    final success = await AuthService.registerBiometric();
    loading = false;

    if (!success) {
      error = 'Gagal mendaftarkan biometric ke server';
      notifyListeners();
      return;
    }

    bioEmailCtrl.clear();
    bioPassCtrl.clear();
    onSuccess();
  }

  Future<void> loginWithBiometric(
    BuildContext context,
    VoidCallback onSuccess,
  ) async {
    final canCheck = await _localAuth.canCheckBiometrics;
    if (!canCheck) {
      error = 'Perangkat tidak mendukung biometric';
      notifyListeners();
      return;
    }

    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Gunakan sidik jari untuk masuk',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (!authenticated) return;

      loading = true;
      notifyListeners();

      final result = await AuthService.loginWithBiometric();
      loading = false;

      if (result['status'] == 200) {
        onSuccess();
      } else {
        error = result['data']['message'] ?? 'Biometric login gagal';
        notifyListeners();
      }
    } catch (e) {
      loading = false;
      error = 'Biometric gagal: $e';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    regNameCtrl.dispose();
    regEmailCtrl.dispose();
    regPassCtrl.dispose();
    regConfirmPassCtrl.dispose();
    bioEmailCtrl.dispose();
    bioPassCtrl.dispose();
    super.dispose();
  }
}