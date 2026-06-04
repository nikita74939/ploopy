import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../../../core/network/auth_session_guard.dart';
import '../models/schedule_model.dart';

abstract class ScheduleRemoteDataSource {
  Future<List<ScheduleModel>> getSchedulesByDate(DateTime date);
  Future<List<ScheduleModel>> getAllSchedules();
  Future<ScheduleModel?> getScheduleById(int id);
  Future<ScheduleModel> addSchedule(ScheduleModel schedule);
  Future<ScheduleModel> updateSchedule(ScheduleModel schedule);
  Future<void> deleteSchedule(int id);
  Future<List<ScheduleModel>> getUpcomingSchedules(String userId);
}

class ScheduleRemoteDataSourceImpl implements ScheduleRemoteDataSource {
  final http.Client client;
  final String baseUrl;
  final FlutterSecureStorage secureStorage;

  ScheduleRemoteDataSourceImpl({
    required this.client,
    required this.baseUrl,
    required this.secureStorage,
  });

  @override
  Future<List<ScheduleModel>> getSchedulesByDate(DateTime date) async {
    final response = await client
        .get(
          _uri('/api/schedules', {
            'date': DateTime(date.year, date.month, date.day).toIso8601String(),
          }),
          headers: await _jsonHeaders(),
        )
        .timeout(const Duration(seconds: 5));
    return _scheduleList(_decode(response)['schedules'] as List?);
  }

  @override
  Future<List<ScheduleModel>> getAllSchedules() async {
    final response = await client
        .get(_uri('/api/schedules'), headers: await _jsonHeaders())
        .timeout(const Duration(seconds: 5));
    return _scheduleList(_decode(response)['schedules'] as List?);
  }

  @override
  Future<ScheduleModel?> getScheduleById(int id) async {
    final response = await client
        .get(_uri('/api/schedules/$id'), headers: await _jsonHeaders())
        .timeout(const Duration(seconds: 5));
    final data = _decode(response)['schedule'] as Map<String, dynamic>?;
    return data == null ? null : ScheduleModel.fromJson(data);
  }

  @override
  Future<ScheduleModel> addSchedule(ScheduleModel schedule) async {
    final response = await client
        .post(
          _uri('/api/schedules'),
          headers: await _jsonHeaders(),
          body: jsonEncode(schedule.toJson()),
        )
        .timeout(const Duration(seconds: 5));
    return ScheduleModel.fromJson(
      _decode(response)['schedule'] as Map<String, dynamic>,
    );
  }

  @override
  Future<ScheduleModel> updateSchedule(ScheduleModel schedule) async {
    final response = await client
        .patch(
          _uri('/api/schedules/${schedule.remoteId ?? schedule.id}'),
          headers: await _jsonHeaders(),
          body: jsonEncode(schedule.toJson()),
        )
        .timeout(const Duration(seconds: 5));
    return ScheduleModel.fromJson(
      _decode(response)['schedule'] as Map<String, dynamic>,
    );
  }

  @override
  Future<void> deleteSchedule(int id) async {
    final response = await client
        .delete(_uri('/api/schedules/$id'), headers: await _jsonHeaders())
        .timeout(const Duration(seconds: 5));
    _decode(response);
  }

  @override
  Future<List<ScheduleModel>> getUpcomingSchedules(String userId) async {
    final response = await client
        .get(
          _uri('/api/schedules', {'upcoming': 'true'}),
          headers: await _jsonHeaders(),
        )
        .timeout(const Duration(seconds: 5));
    return _scheduleList(_decode(response)['schedules'] as List?);
  }

  List<ScheduleModel> _scheduleList(List? rows) {
    return (rows ?? [])
        .map((row) => ScheduleModel.fromJson(row as Map<String, dynamic>))
        .toList();
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
