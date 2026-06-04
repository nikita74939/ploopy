import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../../../core/network/auth_session_guard.dart';
import '../models/event_model.dart';

abstract class EventRemoteDataSource {
  Future<List<EventModel>> getAllEvents();
  Future<List<EventModel>> getUpcomingEvents();
  Future<EventModel?> getEventById(String id);
  Future<EventModel> createEvent(EventModel event);
  Future<EventModel> updateEvent(EventModel event);
  Future<void> deleteEvent(String id);
  Future<void> joinEvent(String eventId, String userId);
  Future<void> leaveEvent(String eventId, String userId);
}

class EventRemoteDataSourceImpl implements EventRemoteDataSource {
  final http.Client client;
  final String baseUrl;
  final FlutterSecureStorage secureStorage;

  EventRemoteDataSourceImpl({
    required this.client,
    required this.baseUrl,
    required this.secureStorage,
  });

  @override
  Future<List<EventModel>> getAllEvents() async {
    final response = await client
        .get(_uri('/api/events'), headers: await _jsonHeaders())
        .timeout(const Duration(seconds: 8));
    return _eventList(_decode(response)['events'] as List?);
  }

  @override
  Future<List<EventModel>> getUpcomingEvents() async {
    final response = await client
        .get(
          _uri('/api/events', {'upcoming': 'true'}),
          headers: await _jsonHeaders(),
        )
        .timeout(const Duration(seconds: 8));
    return _eventList(_decode(response)['events'] as List?);
  }

  @override
  Future<EventModel?> getEventById(String id) async {
    final response = await client
        .get(_uri('/api/events/$id'), headers: await _jsonHeaders())
        .timeout(const Duration(seconds: 8));
    final event = _decode(response)['event'] as Map<String, dynamic>?;
    return event == null ? null : EventModel.fromJson(event);
  }

  @override
  Future<EventModel> createEvent(EventModel event) async {
    final response = await client
        .post(
          _uri('/api/events'),
          headers: await _jsonHeaders(),
          body: jsonEncode(event.toApiJson()),
        )
        .timeout(const Duration(seconds: 8));
    return EventModel.fromJson(
      _decode(response)['event'] as Map<String, dynamic>,
    );
  }

  @override
  Future<EventModel> updateEvent(EventModel event) async {
    final response = await client
        .patch(
          _uri('/api/events/${event.id}'),
          headers: await _jsonHeaders(),
          body: jsonEncode(event.toApiJson()),
        )
        .timeout(const Duration(seconds: 8));
    return EventModel.fromJson(
      _decode(response)['event'] as Map<String, dynamic>,
    );
  }

  @override
  Future<void> deleteEvent(String id) async {
    final response = await client
        .delete(_uri('/api/events/$id'), headers: await _jsonHeaders())
        .timeout(const Duration(seconds: 8));
    _decode(response);
  }

  @override
  Future<void> joinEvent(String eventId, String userId) async {
    final response = await client
        .post(_uri('/api/events/$eventId/join'), headers: await _jsonHeaders())
        .timeout(const Duration(seconds: 8));
    _decode(response);
  }

  @override
  Future<void> leaveEvent(String eventId, String userId) async {
    final response = await client
        .delete(
          _uri('/api/events/$eventId/join'),
          headers: await _jsonHeaders(),
        )
        .timeout(const Duration(seconds: 8));
    _decode(response);
  }

  List<EventModel> _eventList(List? rows) {
    return (rows ?? [])
        .map((row) => EventModel.fromJson(row as Map<String, dynamic>))
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
    if (response.statusCode == 401) AuthSessionGuard.notifyExpired();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        body['message']?.toString() ?? 'Request gagal. Coba lagi.',
      );
    }
    return body;
  }
}
