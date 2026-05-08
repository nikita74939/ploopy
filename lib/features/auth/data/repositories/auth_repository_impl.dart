import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:isar/isar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../datasources/auth_local_data_source.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final FlutterSecureStorage secureStorage;
  final LocalAuthentication localAuth;
  final Isar isar;
  final SupabaseClient supabase;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.secureStorage,
    required this.localAuth,
    required this.isar,
    required this.supabase,
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
      if (response['success'] == true) {
        final user = UserModel.fromSupabase(
            response['user'] as Map<String, dynamic>);
        await _local.saveUser(user);
        await _local.saveToken(response['token'] as String);
        return user;
      }
      return null;
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<UserModel?> register(
      String email, String password, String name) async {
    try {
      final response =
          await remoteDataSource.register(email, password, name);
      if (response['success'] == true) {
        final user = UserModel.fromSupabase(
            response['user'] as Map<String, dynamic>);
        await _local.saveUser(user);
        await _local.saveToken(response['token'] as String);
        return user;
      }
      return null;
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    await remoteDataSource.forgotPassword(email);
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    // Coba ambil dari cache lokal dulu
    final localUser = await _local.getCurrentUser();
    if (localUser != null) return localUser;

    // Fallback ke Supabase jika cache kosong
    try {
      final data = await remoteDataSource.getCurrentUserData();
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
    await remoteDataSource.logout();
    await _local.deleteToken();
  }

  @override
  Future<bool> authenticateWithBiometrics() async {
    return await _local.authenticateWithBiometrics();
  }

  @override
  Future<bool> isLoggedIn() async {
    // Cek sesi aktif di Supabase
    final session = supabase.auth.currentSession;
    if (session != null && !_isTokenExpired(session.expiresAt)) {
      return true;
    }
    // Fallback: cek token lokal
    final token = await _local.getToken();
    return token != null;
  }

  bool _isTokenExpired(int? expiresAt) {
    if (expiresAt == null) return true;
    final expiry =
        DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000);
    return DateTime.now().isAfter(expiry);
  }
}