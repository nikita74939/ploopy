import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../../../core/network/auth_session_guard.dart';
import '../models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications();
  Future<void> markAsRead(String remoteId);
  Future<void> markAllAsRead();
  Future<void> deleteNotification(String remoteId);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final http.Client client;
  final String baseUrl;
  final FlutterSecureStorage secureStorage;

  NotificationRemoteDataSourceImpl({
    required this.client,
    required this.baseUrl,
    required this.secureStorage,
  });

  @override
  Future<List<NotificationModel>> getNotifications() async {
    final response = await client
        .get(_uri('/api/notifications'), headers: await _jsonHeaders())
        .timeout(const Duration(seconds: 8));
    final rows = _decode(response)['notifications'] as List? ?? [];
    return rows
        .map((row) => NotificationModel.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> markAsRead(String remoteId) async {
    final response = await client
        .patch(
          _uri('/api/notifications/$remoteId/read'),
          headers: await _jsonHeaders(),
          body: jsonEncode({'read': true}),
        )
        .timeout(const Duration(seconds: 8));
    _decode(response);
  }

  @override
  Future<void> markAllAsRead() async {
    final response = await client
        .patch(
          _uri('/api/notifications/read-all'),
          headers: await _jsonHeaders(),
        )
        .timeout(const Duration(seconds: 8));
    _decode(response);
  }

  @override
  Future<void> deleteNotification(String remoteId) async {
    final response = await client
        .delete(
          _uri('/api/notifications/$remoteId'),
          headers: await _jsonHeaders(),
        )
        .timeout(const Duration(seconds: 8));
    _decode(response);
  }

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

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
    if (response.statusCode == 401) AuthSessionGuard.notifyExpired();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        body['message']?.toString() ?? 'Request gagal. Coba lagi.',
      );
    }
    return body;
  }
}
