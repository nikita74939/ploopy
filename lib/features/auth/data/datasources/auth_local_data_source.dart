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
  Future<void> saveBiometricToken(String token);
  Future<String?> getBiometricToken();
  Future<void> saveBiometricFlag(String userId, bool enabled);
  Future<bool> isBiometricEnabled();
  Future<void> deleteBiometricToken();
  Future<void> restoreBiometricToken();
  Future<void> deleteSessionToken();
  Future<void> deleteToken();
  Future<void> clearSession({required bool preserveBiometric});
  Future<void> clearUser();
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
    final userId = await secureStorage.read(key: 'current_user_id');
    if (userId != null) {
      final user = await isar.userModels.getByUserId(userId);
      if (user != null) return user;
    }

    // Fallback: ambil user pertama yang ada
    final users = await isar.userModels.where().findAll();
    return users.isNotEmpty ? users.first : null;
  }

  @override
  Future<void> saveUser(UserModel user) async {
    await isar.writeTxn(() async {
      // Cek apakah user sudah ada untuk preserve local-only fields
      final existing = await isar.userModels.getByUserId(user.userId);
      if (existing != null) {
        // Preserve local-only stats agar tidak tertimpa saat refresh dari Supabase
        user
          ..streak = existing.streak
          ..longestStreak = existing.longestStreak
          ..totalStudyMinutes = existing.totalStudyMinutes
          ..totalTasksCompleted = existing.totalTasksCompleted
          ..appLockEnabled = existing.appLockEnabled;
      }
      await isar.userModels.putByUserId(user);
    });
    // Simpan userId aktif agar getCurrentUser bisa menemukannya
    await secureStorage.write(key: 'current_user_id', value: user.userId);
  }

  @override
  Future<UserModel?> getUserByEmail(String email) async {
    return await isar.userModels.getByEmail(email);
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
  Future<void> saveBiometricToken(String token) async {
    await secureStorage.write(key: 'biometric_auth_token', value: token);
  }

  @override
  Future<String?> getBiometricToken() async {
    return await secureStorage.read(key: 'biometric_auth_token');
  }

  @override
  Future<void> saveBiometricFlag(String userId, bool enabled) async {
    await secureStorage.write(
      key: 'biometric_enabled',
      value: enabled ? 'true' : 'false',
    );
    if (enabled) {
      await secureStorage.write(key: 'biometric_user_id', value: userId);
    } else {
      await secureStorage.delete(key: 'biometric_user_id');
    }
  }

  @override
  Future<bool> isBiometricEnabled() async {
    final enabled = await secureStorage.read(key: 'biometric_enabled');
    final token = await getBiometricToken();
    return enabled == 'true' && token != null && token.isNotEmpty;
  }

  @override
  Future<void> deleteBiometricToken() async {
    await secureStorage.delete(key: 'biometric_auth_token');
    await secureStorage.delete(key: 'biometric_enabled');
    await secureStorage.delete(key: 'biometric_user_id');
  }

  @override
  Future<void> restoreBiometricToken() async {
    final token = await getBiometricToken();
    if (token != null && token.isNotEmpty) {
      await saveToken(token);
    }
  }

  @override
  Future<void> deleteSessionToken() async {
    await secureStorage.delete(key: 'auth_token');
  }

  @override
  Future<void> deleteToken() async {
    await secureStorage.delete(key: 'auth_token');
    await secureStorage.delete(key: 'current_user_id');
    await deleteBiometricToken();
  }

  @override
  Future<void> clearSession({required bool preserveBiometric}) async {
    await secureStorage.delete(key: 'auth_token');
    if (!preserveBiometric) {
      await secureStorage.delete(key: 'current_user_id');
      await deleteBiometricToken();
    }
  }

  @override
  Future<void> clearUser() async {
    await isar.writeTxn(() async {
      await isar.userModels.clear();
    });
    await deleteToken();
  }

  @override
  Future<bool> authenticateWithBiometrics() async {
    try {
      final canAuthenticate =
          await localAuth.canCheckBiometrics ||
          await localAuth.isDeviceSupported();
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
