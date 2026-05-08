import '../../data/models/user_model.dart';

abstract class AuthRepository {
  Future<UserModel?> login(String email, String password);
  Future<UserModel?> register(String email, String password, String name);
  Future<void> forgotPassword(String email);
  Future<UserModel?> getCurrentUser();
  Future<void> logout();
  Future<bool> authenticateWithBiometrics();
  Future<bool> isLoggedIn();
}