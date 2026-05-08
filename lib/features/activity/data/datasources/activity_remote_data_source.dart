import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/activity_model.dart';
import '../models/activity_comment_model.dart';

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
  final SupabaseClient supabase;

  ActivityRemoteDataSourceImpl({required this.supabase});

  // ✅ Base query dengan joined profiles dan images
  static const _activitiesQuery = '''
    *,
    profiles:user_id (
      name,
      avatar_url
    ),
    activity_images (
      image_url,
      order_index
    )
  ''';

  @override
  Future<List<ActivityModel>> getAllActivities() async {
    // ✅ Query dari VIEW activities_with_stats
    final response = await supabase
        .from('activities_with_stats') // ← GANTI DI SINI
        .select(_activitiesQuery)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => ActivityModel.fromJson(json))
        .toList();
  }

  @override
  Future<List<ActivityModel>> getActivitiesByUser(String userId) async {
    // ✅ Query dari VIEW activities_with_stats
    final response = await supabase
        .from('activities_with_stats') // ← GANTI DI SINI
        .select(_activitiesQuery)
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => ActivityModel.fromJson(json))
        .toList();
  }

  @override
  Future<ActivityModel?> getActivityById(String id) async {
    // ✅ Query dari VIEW activities_with_stats
    final response = await supabase
        .from('activities_with_stats') // ← GANTI DI SINI
        .select(_activitiesQuery)
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return ActivityModel.fromJson(response);
  }

  @override
  Future<ActivityModel> createActivity({
    required String userId,
    required String text,
    String? location,
    String? achievementId,
    List<String>? imageUrls,
  }) async {
    // 1. Insert ke tabel base activities
    final activityJson = await supabase
        .from('activities')
        .insert({
          'user_id': userId,
          'text': text,
          if (location != null) 'location': location,
          if (achievementId != null) 'achievement_id': achievementId,
        })
        .select()
        .single();

    final activityId = activityJson['id'] as String;

    // 2. Insert images if any
    if (imageUrls != null && imageUrls.isNotEmpty) {
      final imageRows = imageUrls
          .asMap()
          .entries
          .map(
            (entry) => {
              'activity_id': activityId,
              'image_url': entry.value,
              'order_index': entry.key,
            },
          )
          .toList();

      await supabase.from('activity_images').insert(imageRows);
    }

    // 3. Return dari VIEW
    return (await getActivityById(activityId))!;
  }

  @override
  Future<void> deleteActivity(String id) async {
    await supabase.from('activities').delete().eq('id', id);
  }

  @override
  Future<void> toggleLike(String activityId, String userId) async {
    final existing = await supabase
        .from('activity_likes')
        .select('id')
        .eq('activity_id', activityId)
        .eq('user_id', userId)
        .maybeSingle();

    if (existing != null) {
      await supabase
          .from('activity_likes')
          .delete()
          .eq('activity_id', activityId)
          .eq('user_id', userId);
    } else {
      await supabase.from('activity_likes').insert({
        'activity_id': activityId,
        'user_id': userId,
      });
    }
  }

  @override
  Future<List<ActivityCommentModel>> getComments(String activityId) async {
    final response = await supabase
        .from('activity_comments')
        .select('''
          *,
          profiles:user_id (
            name,
            avatar_url
          )
        ''')
        .eq('activity_id', activityId)
        .order('created_at', ascending: true);

    return (response as List)
        .map((json) => ActivityCommentModel.fromJson(json))
        .toList();
  }

  @override
  Future<ActivityCommentModel> addComment({
    required String activityId,
    required String userId,
    required String content,
  }) async {
    final response = await supabase
        .from('activity_comments')
        .insert({
          'activity_id': activityId,
          'user_id': userId,
          'content': content,
        })
        .select('''
          *,
          profiles:user_id (
            name,
            avatar_url
          )
        ''')
        .single();

    return ActivityCommentModel.fromJson(response);
  }
}
