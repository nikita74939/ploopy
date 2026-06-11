import '../../domain/repositories/activity_repository.dart';
import '../../domain/entities/activity_comment_entity.dart';
import '../../domain/entities/activity_entity.dart';
import '../datasources/activity_remote_data_source.dart';

class ActivityRepositoryImpl implements ActivityRepository {
  final ActivityRemoteDataSource remoteDataSource;

  ActivityRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ActivityEntity>> getAllActivities() async {
    final activities = await remoteDataSource.getAllActivities();
    return activities.map((activity) => activity.toEntity()).toList();
  }

  @override
  Future<List<ActivityEntity>> getActivitiesByUser(String userId) async {
    final activities = await remoteDataSource.getActivitiesByUser(userId);
    return activities.map((activity) => activity.toEntity()).toList();
  }

  @override
  Future<ActivityEntity?> getActivityById(String id) async {
    final activity = await remoteDataSource.getActivityById(id);
    return activity?.toEntity();
  }

  @override
  Future<ActivityEntity> createActivity({
    required String userId,
    required String text,
    String? achievementId,
    List<String>? imageUrls,
  }) async {
    final activity = await remoteDataSource.createActivity(
      userId: userId,
      text: text,
      achievementId: achievementId,
      imageUrls: imageUrls,
    );
    return activity.toEntity();
  }

  @override
  Future<String> uploadImage({
    required List<int> bytes,
    required String contentType,
  }) => remoteDataSource.uploadImage(bytes: bytes, contentType: contentType);

  @override
  Future<void> deleteActivity(String id) => remoteDataSource.deleteActivity(id);

  @override
  Future<void> toggleLike(String activityId, String userId) =>
      remoteDataSource.toggleLike(activityId, userId);

  @override
  Future<List<ActivityCommentEntity>> getComments(String activityId) async {
    final comments = await remoteDataSource.getComments(activityId);
    return comments.map((comment) => comment.toEntity()).toList();
  }

  @override
  Future<ActivityCommentEntity> addComment({
    required String activityId,
    required String userId,
    required String content,
  }) async {
    final comment = await remoteDataSource.addComment(
      activityId: activityId,
      userId: userId,
      content: content,
    );
    return comment.toEntity();
  }
}
