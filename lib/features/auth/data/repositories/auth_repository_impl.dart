import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:isar/isar.dart';
import 'package:local_auth/local_auth.dart';

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
  Future<UserModel?> login(String email, String password) async {
    try {
      final response = await remoteDataSource.login(email, password);
      if (response['success'] != true) return null;

      final user = UserModel.fromSupabase(
        response['user'] as Map<String, dynamic>,
      );
      final token = response['token'] as String;

      await _local.saveUser(user);
      await _local.saveToken(token);
      return user;
    } catch (e) {
      throw Exception(_mapAuthError(_cleanError(e)));
    }
  }

  @override
  Future<AuthRegisterResult?> register(
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
      final requiresEmailConfirmation =
          response['requiresEmailConfirmation'] as bool? ?? false;

      await _local.saveUser(user);
      if (token.isNotEmpty) {
        await _local.saveToken(token);
      }

      return AuthRegisterResult(
        user: user,
        isAuthenticated: token.isNotEmpty && !requiresEmailConfirmation,
        requiresEmailConfirmation: requiresEmailConfirmation,
      );
    } catch (e) {
      throw Exception(_mapAuthError(_cleanError(e)));
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    await remoteDataSource.forgotPassword(email);
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final localUser = await _local.getCurrentUser();
    if (localUser != null) return localUser;

    final token = await _local.getToken();
    if (token == null || token.isEmpty) return null;

    try {
      final data = await remoteDataSource.getCurrentUserData(token);
      if (data == null) return null;
      final user = UserModel.fromSupabase(data);
      await _local.saveUser(user);
      return user;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> logout() async {
    final token = await _local.getToken();
    try {
      if (token != null && token.isNotEmpty) {
        await remoteDataSource.logout(token);
      }
    } catch (_) {
      // Local logout still succeeds when backend is unavailable.
    }
    await _local.clearUser();
  }

  @override
  Future<bool> authenticateWithBiometrics() async {
    return await _local.authenticateWithBiometrics();
  }

  @override
  Future<UserModel?> enableBiometric() async {
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
        final data = await remoteDataSource.updateBiometricEnabled(
          token,
          user.userId,
          true,
        );
        final syncedUser = UserModel.fromSupabase(data);
        await _local.saveUser(syncedUser);
        return syncedUser;
      }
    } catch (_) {
      // Backend sync can be retried later; local biometric remains enabled.
    }

    return user;
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
    if (msg.contains('invalid login credentials') ||
        msg.contains('invalid credentials')) {
      return 'Email atau password salah.';
    }
    if (msg.contains('email not confirmed')) {
      return 'Email belum dikonfirmasi. Periksa kotak masuk kamu.';
    }
    if (msg.contains('user already registered') ||
        msg.contains('already registered')) {
      return 'Email sudah terdaftar. Silakan login.';
    }
    if (msg.contains('password should be at least')) {
      return 'Password minimal 6 karakter.';
    }
    return raw;
  }
}
