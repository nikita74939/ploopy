import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class SessionService {
  static const String baseUrl = 'http://192.168.100.147:3000/api';

  // Cek sesi aktif
  static Future<bool> isLoggedIn() async {
    final token = await AuthService.getToken();
    if (token == null) return false;

    try {
      final res = await http.get(
        Uri.parse('$baseUrl/profile'),
        headers: {'Authorization': 'Bearer $token'},
      );
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Ambil data user
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    final token = await AuthService.getToken();
    if (token == null) return null;

    try {
      final res = await http.get(
        Uri.parse('$baseUrl/user/profile'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
