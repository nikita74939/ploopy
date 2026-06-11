import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/network/auth_session_guard.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login(String email, String password);
  Future<Map<String, dynamic>> register(
    String email,
    String password,
    String name,
  );
  Future<void> logout(String token);
  Future<Map<String, dynamic>?> getCurrentUserData(String token);
  Future<Map<String, dynamic>> updateBiometricEnabled(
    String token,
    String userId,
    bool enabled,
  );
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;
  final String baseUrl;

  AuthRemoteDataSourceImpl({required this.client, required this.baseUrl});

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await client.post(
      _uri('/api/auth/login'),
      headers: _jsonHeaders(),
      body: jsonEncode({'email': email, 'password': password}),
    );

    final data = _decode(response);
    return {
      'success': true,
      'token': data['token'] ?? '',
      'refreshToken': data['refreshToken'] ?? '',
      'expiresAt': data['expiresAt'],
      'user': data['user'],
    };
  }

  @override
  Future<Map<String, dynamic>> register(
    String email,
    String password,
    String name,
  ) async {
    final response = await client.post(
      _uri('/api/auth/register'),
      headers: _jsonHeaders(),
      body: jsonEncode({'email': email, 'password': password, 'name': name}),
    );

    final data = _decode(response);
    return {
      'success': true,
      'token': data['token'] ?? '',
      'refreshToken': data['refreshToken'] ?? '',
      'expiresAt': data['expiresAt'],
      'user': data['user'],
    };
  }

  @override
  Future<void> logout(String token) async {
    final response = await client.post(
      _uri('/api/auth/logout'),
      headers: _jsonHeaders(token: token),
    );

    _decode(response);
  }

  @override
  Future<Map<String, dynamic>?> getCurrentUserData(String token) async {
    final response = await client.get(
      _uri('/api/auth/me'),
      headers: _jsonHeaders(token: token),
    );

    final data = _decode(response);
    return data['user'] as Map<String, dynamic>?;
  }

  @override
  Future<Map<String, dynamic>> updateBiometricEnabled(
    String token,
    String userId,
    bool enabled,
  ) async {
    final response = await client.patch(
      _uri('/api/users/$userId/biometric'),
      headers: _jsonHeaders(token: token),
      body: jsonEncode({'enabled': enabled}),
    );

    final data = _decode(response);
    return data['user'] as Map<String, dynamic>;
  }

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Map<String, String> _jsonHeaders({String? token}) {
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Map<String, dynamic> _decode(http.Response response) {
    final body = _decodeBody(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      if (response.statusCode == 401) AuthSessionGuard.notifyExpired();
      throw Exception(
        _messageForStatus(response.statusCode, body['message']?.toString()),
      );
    }

    return body;
  }

  Map<String, dynamic> _decodeBody(String responseBody) {
    if (responseBody.isEmpty) return <String, dynamic>{};
    try {
      final decoded = jsonDecode(responseBody);
      return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  String _messageForStatus(int statusCode, String? backendMessage) {
    if (backendMessage != null && backendMessage.trim().isNotEmpty) {
      return backendMessage.trim();
    }
    if (statusCode == 400) return 'Data yang dikirim belum valid.';
    if (statusCode == 401) return 'Sesi habis. Silakan login lagi.';
    if (statusCode == 403) return 'Kamu tidak punya akses ke fitur ini.';
    if (statusCode == 404) return 'Data tidak ditemukan.';
    if (statusCode >= 500) {
      return 'Server sedang bermasalah. Coba lagi nanti.';
    }
    return 'Request gagal. Coba lagi.';
  }
}
