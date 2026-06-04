import '../../domain/repositories/activity_repository.dart';
import '../datasources/activity_remote_data_source.dart';
import '../models/activity_model.dart';
import '../models/activity_comment_model.dart';

class ActivityRepositoryImpl implements ActivityRepository {
  final ActivityRemoteDataSource remoteDataSource;

  ActivityRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ActivityModel>> getAllActivities() =>
      remoteDataSource.getAllActivities();

  @override
  Future<List<ActivityModel>> getActivitiesByUser(String userId) =>
      remoteDataSource.getActivitiesByUser(userId);

  @override
  Future<ActivityModel?> getActivityById(String id) =>
      remoteDataSource.getActivityById(id);

  @override
  Future<ActivityModel> createActivity({
    required String userId,
    required String text,
    String? location,
    String? achievementId,
    List<String>? imageUrls,
  }) => remoteDataSource.createActivity(
    userId: userId,
    text: text,
    location: location,
    achievementId: achievementId,
    imageUrls: imageUrls,
  );

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
  Future<List<ActivityCommentModel>> getComments(String activityId) =>
      remoteDataSource.getComments(activityId);

  @override
  Future<ActivityCommentModel> addComment({
    required String activityId,
    required String userId,
    required String content,
  }) => remoteDataSource.addComment(
    activityId: activityId,
    userId: userId,
    content: content,
  );
}
