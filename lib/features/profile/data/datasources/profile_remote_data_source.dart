import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../../../../core/network/auth_session_guard.dart';
import '../../../auth/data/models/user_model.dart';
import '../models/achievement_supabase_model.dart';
import '../models/app_settings_model.dart';
import '../models/friendship_model.dart';
import '../models/profile_stats_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserModel?> getUserById(String userId);
  Future<void> updateUser(UserModel user);

  Future<List<AchievementSupabaseModel>> getAllAchievements();
  Future<List<UserAchievementSupabaseModel>> getUserAchievements(String userId);
  Future<void> unlockAchievement(String userId, String achievementId);

  Future<List<FriendshipModel>> getFriends(String userId);
  Future<FriendshipModel> sendFriendRequest(
    String requesterId,
    String addresseeId,
  );
  Future<void> acceptFriendRequest(String friendshipId);
  Future<void> removeFriend(String friendshipId);

  Future<AppSettingsModel> getAppSettings(String userId);
  Future<void> upsertAppSettings(AppSettingsModel settings);

  Future<StreakModel> getStreak(String userId);
  Future<void> upsertStreak(StreakModel streak);

  Future<ProfileStatsModel> getProfileStats();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final http.Client client;
  final String baseUrl;
  final FlutterSecureStorage secureStorage;

  ProfileRemoteDataSourceImpl({
    required this.client,
    required this.baseUrl,
    required this.secureStorage,
  });

  // ─── USER ───────────────────────────────────────────────────────────────────

  @override
  Future<UserModel?> getUserById(String userId) async {
    final response = await client.get(
      _uri('/api/users/$userId'),
      headers: await _jsonHeaders(),
    );
    final data = _decode(response)['user'] as Map<String, dynamic>?;
    return data == null ? null : UserModel.fromSupabase(data);
  }

  @override
  Future<void> updateUser(UserModel user) async {
    final response = await client.patch(
      _uri('/api/users/${user.userId}'),
      headers: await _jsonHeaders(),
      body: jsonEncode(user.toSupabase()),
    );
    _decode(response);
  }

  // ─── ACHIEVEMENTS ────────────────────────────────────────────────────────────

  @override
  Future<List<AchievementSupabaseModel>> getAllAchievements() async {
    final response = await client.get(
      _uri('/api/achievements'),
      headers: await _jsonHeaders(),
    );
    final data = _decode(response);
    final achievements = (data['achievements'] as List?) ?? [];

    return achievements
        .map(
          (e) => AchievementSupabaseModel.fromJson(e as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<List<UserAchievementSupabaseModel>> getUserAchievements(
    String userId,
  ) async {
    final response = await client.get(
      _uri('/api/achievements/users/$userId'),
      headers: await _jsonHeaders(),
    );
    final data = _decode(response);
    final userAchievements = (data['userAchievements'] as List?) ?? [];

    return userAchievements
        .map(
          (e) =>
              UserAchievementSupabaseModel.fromJson(e as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<void> unlockAchievement(String userId, String achievementId) async {
    final response = await client.post(
      _uri('/api/achievements/users/$userId'),
      headers: await _jsonHeaders(),
      body: jsonEncode({'achievementId': achievementId}),
    );
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

    if (response.statusCode < 200 || response.statusCode >= 300) {
      if (response.statusCode == 401) AuthSessionGuard.notifyExpired();
      throw Exception(
        body['message']?.toString() ?? 'Request gagal. Coba lagi.',
      );
    }

    return body;
  }

  // ─── FRIENDS ─────────────────────────────────────────────────────────────────

  @override
  Future<List<FriendshipModel>> getFriends(String userId) async {
    final response = await client.get(
      _uri('/api/friends'),
      headers: await _jsonHeaders(),
    );
    final data = _decode(response);
    final rows = (data['friendships'] as List?) ?? [];
    return rows
        .map(
          (row) => FriendshipModel.fromJson(
            row as Map<String, dynamic>,
            currentUserId: userId,
          ),
        )
        .where((friendship) => friendship.isAccepted)
        .toList();
  }

  @override
  Future<FriendshipModel> sendFriendRequest(
    String requesterId,
    String addresseeId,
  ) async {
    final response = await client.post(
      _uri('/api/friends'),
      headers: await _jsonHeaders(),
      body: jsonEncode({'addresseeId': addresseeId}),
    );
    return FriendshipModel.fromJson(
      _decode(response)['friendship'] as Map<String, dynamic>,
    );
  }

  @override
  Future<void> acceptFriendRequest(String friendshipId) async {
    final response = await client.patch(
      _uri('/api/friends/$friendshipId'),
      headers: await _jsonHeaders(),
      body: jsonEncode({'status': 'accepted'}),
    );
    _decode(response);
  }

  @override
  Future<void> removeFriend(String friendshipId) async {
    final response = await client.delete(
      _uri('/api/friends/$friendshipId'),
      headers: await _jsonHeaders(),
    );
    _decode(response);
  }

  // ─── APP SETTINGS ────────────────────────────────────────────────────────────

  @override
  Future<AppSettingsModel> getAppSettings(String userId) async {
    final response = await client.get(
      _uri('/api/settings/me'),
      headers: await _jsonHeaders(),
    );
    final settings = _decode(response)['settings'] as Map<String, dynamic>?;
    return settings == null
        ? AppSettingsModel.defaultFor(userId)
        : AppSettingsModel.fromJson(settings);
  }

  @override
  Future<void> upsertAppSettings(AppSettingsModel settings) async {
    final response = await client.patch(
      _uri('/api/settings/me'),
      headers: await _jsonHeaders(),
      body: jsonEncode(settings.toUpsertJson()),
    );
    _decode(response);
  }

  // ─── STREAKS ─────────────────────────────────────────────────────────────────

  @override
  Future<StreakModel> getStreak(String userId) async {
    final response = await client.get(
      _uri('/api/streaks/me'),
      headers: await _jsonHeaders(),
    );
    final streak = _decode(response)['streak'] as Map<String, dynamic>?;
    return streak == null
        ? StreakModel.defaultFor(userId)
        : StreakModel.fromJson(streak);
  }

  @override
  Future<void> upsertStreak(StreakModel streak) async {
    final response = await client.patch(
      _uri('/api/streaks/me'),
      headers: await _jsonHeaders(),
      body: jsonEncode(streak.toUpsertJson()),
    );
    _decode(response);
  }

  @override
  Future<ProfileStatsModel> getProfileStats() async {
    final response = await client.get(
      _uri('/api/profile/stats'),
      headers: await _jsonHeaders(),
    );
    final stats = _decode(response)['stats'] as Map<String, dynamic>?;
    return ProfileStatsModel.fromJson(stats ?? const <String, dynamic>{});
  }
}
