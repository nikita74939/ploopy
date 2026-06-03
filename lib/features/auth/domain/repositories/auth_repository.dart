import '../../data/models/user_model.dart';

class AuthRegisterResult {
  final UserModel user;
  final bool isAuthenticated;
  final bool requiresEmailConfirmation;

  const AuthRegisterResult({
    required this.user,
    required this.isAuthenticated,
    required this.requiresEmailConfirmation,
  });
}

abstract class AuthRepository {
  Future<UserModel?> login(String email, String password);
  Future<AuthRegisterResult?> register(
    String email,
    String password,
    String name,
  );
  Future<void> forgotPassword(String email);
  Future<UserModel?> getCurrentUser();
  Future<void> logout();
  Future<bool> authenticateWithBiometrics();

  /// Aktifkan biometric: simpan flag di lokal & Supabase, lalu return user terbaru
  Future<UserModel?> enableBiometric();

  Future<bool> isLoggedIn();
}
