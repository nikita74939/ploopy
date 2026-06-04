import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/network/auth_session_guard.dart';
import '../../../auth/data/models/user_model.dart';
import '../models/achievement_supabase_model.dart';
import '../models/app_settings_model.dart';
import '../models/friendship_model.dart';

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
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final SupabaseClient supabase;
  final http.Client client;
  final String baseUrl;
  final FlutterSecureStorage secureStorage;

  ProfileRemoteDataSourceImpl({
    required this.supabase,
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
    await supabase
        .from('users')
        .update(user.toSupabase())
        .eq('id', user.userId);
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
    // Ambil semua friendship dengan status accepted
    // Join ke tabel users untuk mendapatkan data teman
    final asRequester = await supabase
        .from('friendships')
        .select('*, addressee:users!friendships_addressee_id_fkey(*)')
        .eq('requester_id', userId)
        .eq('status', 'accepted');

    final asAddressee = await supabase
        .from('friendships')
        .select('*, requester:users!friendships_requester_id_fkey(*)')
        .eq('addressee_id', userId)
        .eq('status', 'accepted');

    final List<FriendshipModel> friends = [];

    for (final row in (asRequester as List)) {
      friends.add(
        FriendshipModel.fromJson(
          row as Map<String, dynamic>,
          currentUserId: userId,
        ),
      );
    }
    for (final row in (asAddressee as List)) {
      friends.add(
        FriendshipModel.fromJson(
          row as Map<String, dynamic>,
          currentUserId: userId,
        ),
      );
    }

    return friends;
  }

  @override
  Future<FriendshipModel> sendFriendRequest(
    String requesterId,
    String addresseeId,
  ) async {
    final response = await supabase
        .from('friendships')
        .insert({
          'requester_id': requesterId,
          'addressee_id': addresseeId,
          'status': 'pending',
        })
        .select()
        .single();

    return FriendshipModel.fromJson(response);
  }

  @override
  Future<void> acceptFriendRequest(String friendshipId) async {
    await supabase
        .from('friendships')
        .update({'status': 'accepted'})
        .eq('id', friendshipId);
  }

  @override
  Future<void> removeFriend(String friendshipId) async {
    await supabase.from('friendships').delete().eq('id', friendshipId);
  }

  // ─── APP SETTINGS ────────────────────────────────────────────────────────────

  @override
  Future<AppSettingsModel> getAppSettings(String userId) async {
    final response = await supabase
        .from('app_settings')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (response == null) {
      return AppSettingsModel.defaultFor(userId);
    }
    return AppSettingsModel.fromJson(response);
  }

  @override
  Future<void> upsertAppSettings(AppSettingsModel settings) async {
    await supabase
        .from('app_settings')
        .upsert(settings.toUpsertJson(), onConflict: 'user_id');
  }

  // ─── STREAKS ─────────────────────────────────────────────────────────────────

  @override
  Future<StreakModel> getStreak(String userId) async {
    final response = await supabase
        .from('streaks')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (response == null) {
      return StreakModel.defaultFor(userId);
    }
    return StreakModel.fromJson(response);
  }

  @override
  Future<void> upsertStreak(StreakModel streak) async {
    await supabase
        .from('streaks')
        .upsert(streak.toUpsertJson(), onConflict: 'user_id');
  }
}
