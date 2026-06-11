import '../entities/activity_comment_entity.dart';
import '../entities/activity_entity.dart';

abstract class ActivityRepository {
  Future<List<ActivityEntity>> getAllActivities();
  Future<List<ActivityEntity>> getActivitiesByUser(String userId);
  Future<ActivityEntity?> getActivityById(String id);
  Future<ActivityEntity> createActivity({
    required String userId,
    required String text,
    String? achievementId,
    List<String>? imageUrls,
  });
  Future<String> uploadImage({
    required List<int> bytes,
    required String contentType,
  });
  Future<void> deleteActivity(String id);
  Future<void> toggleLike(String activityId, String userId);
  Future<List<ActivityCommentEntity>> getComments(String activityId);
  Future<ActivityCommentEntity> addComment({
    required String activityId,
    required String userId,
    required String content,
  });
}
