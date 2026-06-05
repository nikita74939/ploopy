import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:isar/isar.dart';
import 'package:local_auth/local_auth.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final FlutterSecureStorage secureStorage;
  final LocalAuthentication localAuth;
  final Isar isar;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.secureStorage,
    required this.localAuth,
    required this.isar,
  });

  AuthLocalDataSourceImpl get _local => AuthLocalDataSourceImpl(
    isar: isar,
    secureStorage: secureStorage,
    localAuth: localAuth,
  );

  @override
  Future<UserEntity?> login(String email, String password) async {
    try {
      final response = await remoteDataSource.login(email, password);
      if (response['success'] != true) return null;

      final user = UserModel.fromSupabase(
        response['user'] as Map<String, dynamic>,
      );
      final token = response['token'] as String;

      await _local.saveUser(user);
      await _local.saveToken(token);
      if (user.biometricEnabled) {
        await _local.saveBiometricToken(token);
        await _local.saveBiometricFlag(user.userId, true);
      }
      return user.toEntity();
    } catch (e) {
      throw Exception(_mapAuthError(_cleanError(e)));
    }
  }

  @override
  Future<UserEntity?> register(
    String email,
    String password,
    String name,
  ) async {
    try {
      final response = await remoteDataSource.register(email, password, name);
      if (response['success'] != true) return null;

      final user = UserModel.fromSupabase(
        response['user'] as Map<String, dynamic>,
      );
      final token = response['token'] as String;

      await _local.saveUser(user);
      await _local.saveToken(token);

      return user.toEntity();
    } catch (e) {
      throw Exception(_mapAuthError(_cleanError(e)));
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final token = await _local.getToken();
    if (token == null || token.isEmpty) return null;

    try {
      final data = await remoteDataSource.getCurrentUserData(token);
      if (data == null) return null;
      final user = UserModel.fromSupabase(data);
      await _local.saveUser(user);
      return user.toEntity();
    } catch (e) {
      await _local.clearUser();
      return null;
    }
  }

  @override
  Future<UserEntity?> getCachedUser() async {
    final user = await _local.getCurrentUser();
    return user?.toEntity();
  }

  @override
  Future<void> logout() async {
    final token = await _local.getToken();
    final preserveBiometric = await _local.isBiometricEnabled();
    try {
      if (token != null && token.isNotEmpty) {
        await remoteDataSource.logout(token);
      }
    } catch (_) {
      // Local logout still succeeds when backend is unavailable.
    }
    await _local.clearSession(preserveBiometric: preserveBiometric);
  }

  @override
  Future<bool> hasBiometricLogin() async {
    final user = await _local.getCurrentUser();
    final enabled = await _local.isBiometricEnabled();
    return enabled && user?.biometricEnabled == true;
  }

  @override
  Future<bool> authenticateWithBiometrics() async {
    final authenticated = await _local.authenticateWithBiometrics();
    if (!authenticated) return false;

    final token = await _local.getBiometricToken();
    if (token == null || token.isEmpty) return false;

    await _local.restoreBiometricToken();
    return true;
  }

  @override
  Future<UserEntity?> enableBiometric() async {
    final ok = await _local.authenticateWithBiometrics();
    if (!ok) return null;

    final user = await _local.getCurrentUser();
    if (user == null) return null;

    await isar.writeTxn(() async {
      user.biometricEnabled = true;
      await isar.userModels.putByUserId(user);
    });

    try {
      final token = await _local.getToken();
      if (token != null && token.isNotEmpty) {
        await _local.saveBiometricToken(token);
        await _local.saveBiometricFlag(user.userId, true);
        final data = await remoteDataSource.updateBiometricEnabled(
          token,
          user.userId,
          true,
        );
        final syncedUser = UserModel.fromSupabase(data);
        await _local.saveUser(syncedUser);
        return syncedUser.toEntity();
      }
    } catch (_) {
      // Backend sync can be retried later; local biometric remains enabled.
    }

    return user.toEntity();
  }

  @override
  Future<UserEntity?> setBiometricEnabled(bool enabled) async {
    if (enabled) return enableBiometric();

    final user = await _local.getCurrentUser();
    if (user == null) return null;

    user.biometricEnabled = false;
    await isar.writeTxn(() async {
      await isar.userModels.putByUserId(user);
    });
    await _local.deleteBiometricToken();

    try {
      final token = await _local.getToken();
      if (token != null && token.isNotEmpty) {
        final data = await remoteDataSource.updateBiometricEnabled(
          token,
          user.userId,
          false,
        );
        final syncedUser = UserModel.fromSupabase(data);
        await _local.saveUser(syncedUser);
        return syncedUser.toEntity();
      }
    } catch (_) {
      // Local disable still succeeds when backend is unavailable.
    }

    return user.toEntity();
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await _local.getToken();
    return token != null && token.isNotEmpty;
  }

  String _cleanError(Object e) {
    final msg = e.toString();
    return msg.startsWith('Exception: ') ? msg.substring(11) : msg;
  }

  String _mapAuthError(String raw) {
    final msg = raw.toLowerCase();
    if (msg.contains('socketexception') ||
        msg.contains('connection refused') ||
        msg.contains('failed host lookup') ||
        msg.contains('clientexception')) {
      return 'Tidak bisa terhubung ke server. Periksa koneksi kamu.';
    }
    if (msg.contains('internal server error') ||
        msg.contains('server sedang bermasalah') ||
        msg.contains('500')) {
      return 'Server sedang bermasalah. Coba lagi nanti.';
    }
    if (msg.contains('invalid or expired token') ||
        msg.contains('missing bearer token') ||
        msg.contains('sesi habis')) {
      return 'Sesi habis. Silakan login lagi.';
    }
    if (msg.contains('invalid login credentials') ||
        msg.contains('invalid credentials') ||
        msg.contains('email atau password salah')) {
      return 'Email atau password salah.';
    }
    if (msg.contains('user already registered') ||
        msg.contains('already registered') ||
        msg.contains('email sudah terdaftar')) {
      return 'Email sudah terdaftar. Silakan login.';
    }
    if (msg.contains('password should be at least') ||
        msg.contains('password minimal')) {
      return 'Password minimal 6 karakter.';
    }
    return raw.trim().isEmpty ? 'Terjadi kesalahan. Coba lagi.' : raw;
  }
}
