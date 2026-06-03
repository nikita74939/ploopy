import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity?> login(String email, String password);
  Future<UserEntity?> register(String email, String password, String name);
  Future<UserEntity?> getCurrentUser();
  Future<void> logout();
  Future<bool> authenticateWithBiometrics();

  /// Aktifkan biometric: simpan flag di lokal & Supabase, lalu return user terbaru
  Future<UserEntity?> enableBiometric();

  Future<bool> isLoggedIn();
}
