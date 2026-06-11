import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../../../core/network/auth_session_guard.dart';
import '../../domain/models/study_session_model.dart';

abstract class StudyRemoteDataSource {
  Future<List<StudySessionModel>> getSessionsByDate(
    String userId,
    DateTime date,
  );
  Future<List<StudySessionModel>> getSessionsByUser(String userId);
  Future<int> startSession(String userId);
  Future<void> endSession(int sessionId, int durationMinutes);
  Future<int> getTodayStudyMinutes(String userId);
  Future<int> getStreak(String userId);
  Future<Map<int, int>> getStudyMinutesByDay(
    String userId,
    int year,
    int month,
  );
}

class StudyRemoteDataSourceImpl implements StudyRemoteDataSource {
  final http.Client client;
  final String baseUrl;
  final FlutterSecureStorage secureStorage;

  StudyRemoteDataSourceImpl({
    required this.client,
    required this.baseUrl,
    required this.secureStorage,
  });

  @override
  Future<List<StudySessionModel>> getSessionsByDate(
    String userId,
    DateTime date,
  ) async {
    final response = await client
        .get(
          _uri('/api/study/sessions', {
            'date': DateTime(date.year, date.month, date.day).toIso8601String(),
          }),
          headers: await _jsonHeaders(),
        )
        .timeout(const Duration(seconds: 5));
    return _sessionList(_decode(response)['sessions'] as List?);
  }

  @override
  Future<List<StudySessionModel>> getSessionsByUser(String userId) async {
    final response = await client
        .get(_uri('/api/study/sessions'), headers: await _jsonHeaders())
        .timeout(const Duration(seconds: 5));
    return _sessionList(_decode(response)['sessions'] as List?);
  }

  @override
  Future<int> startSession(String userId) async {
    final response = await client
        .post(_uri('/api/study/sessions'), headers: await _jsonHeaders())
        .timeout(const Duration(seconds: 5));
    final session = _sessionFromJson(
      _decode(response)['session'] as Map<String, dynamic>,
    );
    return session.id;
  }

  @override
  Future<void> endSession(int sessionId, int durationMinutes) async {
    final response = await client
        .patch(
          _uri('/api/study/sessions/$sessionId/end'),
          headers: await _jsonHeaders(),
          body: jsonEncode({'durationMinutes': durationMinutes}),
        )
        .timeout(const Duration(seconds: 5));
    _decode(response);
  }

  @override
  Future<int> getTodayStudyMinutes(String userId) async {
    final response = await client
        .get(_uri('/api/study/today'), headers: await _jsonHeaders())
        .timeout(const Duration(seconds: 5));
    return (_decode(response)['minutes'] as num?)?.toInt() ?? 0;
  }

  @override
  Future<int> getStreak(String userId) async {
    final response = await client
        .get(_uri('/api/streaks/me'), headers: await _jsonHeaders())
        .timeout(const Duration(seconds: 5));
    final streak = _decode(response)['streak'] as Map<String, dynamic>? ?? {};
    return (streak['current_streak'] as num?)?.toInt() ?? 0;
  }

  @override
  Future<Map<int, int>> getStudyMinutesByDay(
    String userId,
    int year,
    int month,
  ) async {
    final response = await client
        .get(
          _uri('/api/study/month', {'year': '$year', 'month': '$month'}),
          headers: await _jsonHeaders(),
        )
        .timeout(const Duration(seconds: 5));
    final rows = _decode(response)['days'] as Map<String, dynamic>? ?? {};
    return rows.map(
      (key, value) => MapEntry(int.parse(key), (value as num).toInt()),
    );
  }

  List<StudySessionModel> _sessionList(List? rows) {
    return (rows ?? [])
        .map((row) => _sessionFromJson(row as Map<String, dynamic>))
        .toList();
  }

  StudySessionModel _sessionFromJson(Map<String, dynamic> json) {
    return StudySessionModel()
      ..id = (json['id'] as num).toInt()
      ..userId = json['user_id']?.toString() ?? ''
      ..startTime = DateTime.parse(json['start_time'].toString())
      ..endTime = json['end_time'] == null
          ? null
          : DateTime.parse(json['end_time'].toString())
      ..durationMinutes = (json['duration_minutes'] as num?)?.toInt() ?? 0;
  }

  Uri _uri(String path, [Map<String, String>? query]) {
    return Uri.parse('$baseUrl$path').replace(queryParameters: query);
  }

  Future<Map<String, String>> _jsonHeaders() async {
    final token = await secureStorage.read(key: 'auth_token');
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Map<String, dynamic> _decode(http.Response response) {
    final body = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode < 200 || response.statusCode >= 300) {
      if (response.statusCode == 401) AuthSessionGuard.notifyExpired();
      throw Exception(
        body['message']?.toString() ?? 'Request gagal. Coba lagi.',
      );
    }

    return body;
  }
}
