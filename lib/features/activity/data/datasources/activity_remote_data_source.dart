import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../../../core/network/auth_session_guard.dart';
import '../models/activity_comment_model.dart';
import '../models/activity_model.dart';

abstract class ActivityRemoteDataSource {
  Future<List<ActivityModel>> getAllActivities();
  Future<List<ActivityModel>> getActivitiesByUser(String userId);
  Future<ActivityModel?> getActivityById(String id);
  Future<ActivityModel> createActivity({
    required String userId,
    required String text,
    String? location,
    String? achievementId,
    List<String>? imageUrls,
  });
  Future<String> uploadImage({
    required List<int> bytes,
    required String contentType,
  });
  Future<void> deleteActivity(String id);
  Future<void> toggleLike(String activityId, String userId);
  Future<List<ActivityCommentModel>> getComments(String activityId);
  Future<ActivityCommentModel> addComment({
    required String activityId,
    required String userId,
    required String content,
  });
}

class ActivityRemoteDataSourceImpl implements ActivityRemoteDataSource {
  final http.Client client;
  final String baseUrl;
  final FlutterSecureStorage secureStorage;

  ActivityRemoteDataSourceImpl({
    required this.client,
    required this.baseUrl,
    required this.secureStorage,
  });

  @override
  Future<List<ActivityModel>> getAllActivities() async {
    final response = await client
        .get(_uri('/api/activities'), headers: await _jsonHeaders())
        .timeout(const Duration(seconds: 8));
    return _activityList(_decode(response)['activities'] as List?);
  }

  @override
  Future<List<ActivityModel>> getActivitiesByUser(String userId) async {
    final response = await client
        .get(
          _uri('/api/activities/users/$userId'),
          headers: await _jsonHeaders(),
        )
        .timeout(const Duration(seconds: 8));
    return _activityList(_decode(response)['activities'] as List?);
  }

  @override
  Future<ActivityModel?> getActivityById(String id) async {
    final activities = await getAllActivities();
    try {
      return activities.firstWhere((activity) => activity.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<ActivityModel> createActivity({
    required String userId,
    required String text,
    String? location,
    String? achievementId,
    List<String>? imageUrls,
  }) async {
    final response = await client
        .post(
          _uri('/api/activities'),
          headers: await _jsonHeaders(),
          body: jsonEncode({
            'text': text,
            if (location != null && location.trim().isNotEmpty)
              'location': location.trim(),
            if (achievementId != null) 'achievementId': achievementId,
            if (imageUrls != null && imageUrls.isNotEmpty) 'images': imageUrls,
          }),
        )
        .timeout(const Duration(seconds: 8));
    final data = _decode(response)['activity'] as Map<String, dynamic>;
    return ActivityModel.fromJson(data);
  }

  @override
  Future<String> uploadImage({
    required List<int> bytes,
    required String contentType,
  }) async {
    final response = await client
        .post(
          _uri('/api/activities/uploads'),
          headers: await _jsonHeaders(),
          body: jsonEncode({
            'base64': base64Encode(bytes),
            'contentType': contentType,
          }),
        )
        .timeout(const Duration(seconds: 20));
    return _decode(response)['imageUrl'].toString();
  }

  @override
  Future<void> deleteActivity(String id) async {
    final response = await client
        .delete(_uri('/api/activities/$id'), headers: await _jsonHeaders())
        .timeout(const Duration(seconds: 8));
    _decode(response);
  }

  @override
  Future<void> toggleLike(String activityId, String userId) async {
    final response = await client
        .post(
          _uri('/api/activities/$activityId/like'),
          headers: await _jsonHeaders(),
        )
        .timeout(const Duration(seconds: 8));
    _decode(response);
  }

  @override
  Future<List<ActivityCommentModel>> getComments(String activityId) async {
    final response = await client
        .get(
          _uri('/api/activities/$activityId/comments'),
          headers: await _jsonHeaders(),
        )
        .timeout(const Duration(seconds: 8));
    return _commentList(_decode(response)['comments'] as List?);
  }

  @override
  Future<ActivityCommentModel> addComment({
    required String activityId,
    required String userId,
    required String content,
  }) async {
    final response = await client
        .post(
          _uri('/api/activities/$activityId/comments'),
          headers: await _jsonHeaders(),
          body: jsonEncode({'content': content}),
        )
        .timeout(const Duration(seconds: 8));
    return ActivityCommentModel.fromJson(
      _decode(response)['comment'] as Map<String, dynamic>,
    );
  }

  List<ActivityModel> _activityList(List? rows) => (rows ?? [])
      .map((row) => ActivityModel.fromJson(row as Map<String, dynamic>))
      .toList();

  List<ActivityCommentModel> _commentList(List? rows) => (rows ?? [])
      .map((row) => ActivityCommentModel.fromJson(row as Map<String, dynamic>))
      .toList();

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

    if (response.statusCode == 401) {
      AuthSessionGuard.notifyExpired();
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        body['message']?.toString() ?? 'Request gagal. Coba lagi.',
      );
    }

    return body;
  }
}
