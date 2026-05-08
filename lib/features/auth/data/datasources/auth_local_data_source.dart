import 'package:isar/isar.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<UserModel?> getCurrentUser();
  Future<void> saveUser(UserModel user);
  Future<UserModel?> getUserByEmail(String email);
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> deleteToken();
  Future<bool> authenticateWithBiometrics();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final Isar isar;
  final FlutterSecureStorage secureStorage;
  final LocalAuthentication localAuth;

  AuthLocalDataSourceImpl({
    required this.isar,
    required this.secureStorage,
    required this.localAuth,
  });

  @override
  Future<UserModel?> getCurrentUser() async {
    final token = await getToken();
    if (token == null) return null;

    final users = await isar.userModels.where().findAll();
    return users.isNotEmpty ? users.first : null;
  }

  @override
  Future<void> saveUser(UserModel user) async {
    await isar.writeTxn(() async {
      await isar.userModels.put(user);
    });
  }

  @override
  Future<UserModel?> getUserByEmail(String email) async {
    return await isar.userModels.filter().emailEqualTo(email).findFirst();
  }

  @override
  Future<void> saveToken(String token) async {
    await secureStorage.write(key: 'auth_token', value: token);
  }

  @override
  Future<String?> getToken() async {
    return await secureStorage.read(key: 'auth_token');
  }

  @override
  Future<void> deleteToken() async {
    await secureStorage.delete(key: 'auth_token');
  }

  @override
  Future<bool> authenticateWithBiometrics() async {
    try {
      final canAuthenticate = await localAuth.canCheckBiometrics;
      if (!canAuthenticate) return false;

      final availableBiometrics = await localAuth.getAvailableBiometrics();
      if (availableBiometrics.isEmpty) return false;

      return await localAuth.authenticate(
        localizedReason: 'Authenticate to access Ploopy',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }
}