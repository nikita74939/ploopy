import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../../../core/network/auth_session_guard.dart';
import '../models/ai_daily_plan_model.dart';

class GroqAiService {
  final http.Client client;
  final String baseUrl;
  final FlutterSecureStorage secureStorage;

  GroqAiService({
    required this.client,
    required this.baseUrl,
    required this.secureStorage,
  });

  Future<AiDailyPlanResponseModel> generateDailyPlan(
    AiDailyPlanRequestModel request,
  ) async {
    final response = await client
        .post(
          Uri.parse('$baseUrl/api/ai/daily-plan'),
          headers: await _jsonHeaders(),
          body: jsonEncode(request.toJson()),
        )
        .timeout(const Duration(seconds: 30));

    final body = _decodeBody(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      if (response.statusCode == 401) AuthSessionGuard.notifyExpired();
      throw Exception(
        body['message']?.toString() ?? 'Gagal membuat AI Daily Plan.',
      );
    }

    try {
      final plan = body['plan'];
      if (plan is Map<String, dynamic>) {
        return AiDailyPlanResponseModel.fromJson(plan);
      }

      final raw = body['plan']?.toString() ?? body['content']?.toString();
      final fallback = raw == null ? null : _extractJsonObject(raw);
      if (fallback == null) {
        throw Exception(
          'AI mengembalikan format yang tidak valid. Coba generate ulang.',
        );
      }

      return AiDailyPlanResponseModel.fromJson(
        jsonDecode(fallback) as Map<String, dynamic>,
      );
    } on FormatException {
      throw Exception(
        'AI mengembalikan JSON yang tidak valid. Coba generate ulang.',
      );
    }
  }

  Future<Map<String, String>> _jsonHeaders() async {
    final token = await secureStorage.read(key: 'auth_token');
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Map<String, dynamic> _decodeBody(String raw) {
    if (raw.isEmpty) return <String, dynamic>{};
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  String? _extractJsonObject(String raw) {
    final start = raw.indexOf('{');
    final end = raw.lastIndexOf('}');
    if (start == -1 || end == -1 || end <= start) return null;
    return raw.substring(start, end + 1);
  }
}
