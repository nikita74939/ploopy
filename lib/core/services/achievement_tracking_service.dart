import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../network/auth_session_guard.dart';

class AchievementTrackingService {
  AchievementTrackingService._();

  static final http.Client _client = http.Client();
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  static Future<void> track(String eventType, {int amount = 1}) async {
    final token = await _secureStorage.read(key: 'auth_token');
    if (token == null || token.isEmpty) return;

    try {
      final response = await _client
          .post(
            Uri.parse('${ApiConfig.baseUrl}/api/achievements/track'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'eventType': eventType,
              'amount': amount < 1 ? 1 : amount,
            }),
          )
          .timeout(const Duration(seconds: 6));

      if (response.statusCode == 401) {
        AuthSessionGuard.notifyExpired();
      }
    } catch (_) {
      // Achievement tracking should never block the tool workflow.
    }
  }
}
