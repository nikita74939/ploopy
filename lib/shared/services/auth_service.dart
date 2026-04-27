import 'dart:convert';
import 'package:http/http.dart' as http;
import 'storage_service.dart';

class AuthService {
  static const String _baseUrl = 'http://172.16.17.59:3000/api';

  // LOGIN
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = jsonDecode(res.body);

    if (res.statusCode == 200) {
      await _saveCredentials(data['token'], data['user']['id'].toString());
    }
    return {'status': res.statusCode, 'data': data};
  }

  // REGISTER ⭐ NEW
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );
    final data = jsonDecode(res.body);
    return {'status': res.statusCode, 'data': data};
  }

  // BIOMETRIC REGISTER
  static Future<bool> registerBiometric() async {
    final token = await getToken();
    if (token == null) return false;

    final res = await http.post(
      Uri.parse('$_baseUrl/auth/biometric-register'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      await StorageService.write('biometric_token', data['biometric_token']);
      return true;
    }
    return false;
  }

  // BIOMETRIC LOGIN
  static Future<Map<String, dynamic>> loginWithBiometric() async {
    final biometricToken = await StorageService.read('biometric_token');
    if (biometricToken == null) {
      return {
        'status': 401,
        'data': {'message': 'Biometric belum didaftarkan'}
      };
    }

    final res = await http.post(
      Uri.parse('$_baseUrl/auth/biometric-login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'biometric_token': biometricToken}),
    );

    final data = jsonDecode(res.body);
    if (res.statusCode == 200) {
      await _saveCredentials(data['token'], data['user']['id'].toString());
    }
    return {'status': res.statusCode, 'data': data};
  }

  static Future<bool> hasBiometricToken() async {
    final token = await StorageService.read('biometric_token');
    return token != null;
  }

  static Future<void> logout() async {
    await StorageService.delete('jwt_token');
    await StorageService.delete('user_id');
  }

  static Future<String?> getToken() async {
    return await StorageService.read('jwt_token');
  }

  static Future<void> _saveCredentials(String token, String userId) async {
    await Future.wait([
      StorageService.write('jwt_token', token),
      StorageService.write('user_id', userId),
    ]);
  }
}