import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity?> login(String email, String password);
  Future<UserEntity?> register(String email, String password, String name);
  Future<UserEntity?> getCurrentUser();
  Future<UserEntity?> getCachedUser();
  Future<void> logout();
  Future<bool> hasBiometricLogin();
  Future<bool> authenticateWithBiometrics();

  /// Aktifkan biometric: simpan flag di lokal & Supabase, lalu return user terbaru
  Future<UserEntity?> enableBiometric();
  Future<UserEntity?> setBiometricEnabled(bool enabled);

  Future<bool> isLoggedIn();
}
