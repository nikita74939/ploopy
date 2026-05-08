import '../../data/models/activity_model.dart';
import '../../data/models/activity_comment_model.dart';

abstract class ActivityRepository {
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