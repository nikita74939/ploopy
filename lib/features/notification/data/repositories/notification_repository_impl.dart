// lib/features/notification/data/repositories/notification_repository_impl.dart
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_local_data_source.dart';
import '../datasources/notification_remote_data_source.dart';
import '../models/notification_model.dart';
import '../../domain/entities/notification_entity.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationLocalDataSource localDataSource;
  final NotificationRemoteDataSource? remoteDataSource;

  NotificationRepositoryImpl({
    required this.localDataSource,
    this.remoteDataSource,
  });

  @override
  Future<List<NotificationEntity>> getAllNotifications(String userId) async {
    await _refreshRemote(userId);
    final notifications = await localDataSource.getAllNotifications(userId);
    return notifications
        .map((notification) => notification.toEntity())
        .toList();
  }

  @override
  Future<List<NotificationEntity>> getUnreadNotifications(String userId) async {
    final notifications = await localDataSource.getUnreadNotifications(userId);
    return notifications
        .map((notification) => notification.toEntity())
        .toList();
  }

  @override
  Future<void> addNotification(NotificationEntity notification) async {
    await localDataSource.addNotification(
      NotificationModel.fromEntity(notification),
    );
  }

  @override
  Future<void> markAsRead(int id) async {
    final notification = await localDataSource.getNotificationById(id);
    final remoteId = notification?.senderId;
    if (remoteId != null && remoteDataSource != null) {
      await remoteDataSource!.markAsRead(remoteId);
    }
    await localDataSource.markAsRead(id);
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    await remoteDataSource?.markAllAsRead();
    await localDataSource.markAllAsRead(userId);
  }

  @override
  Future<int> getUnreadCount(String userId) async {
    return await localDataSource.getUnreadCount(userId);
  }

  @override
  Future<void> deleteNotification(int id) async {
    final notification = await localDataSource.getNotificationById(id);
    final remoteId = notification?.senderId;
    if (remoteId != null && remoteDataSource != null) {
      await remoteDataSource!.deleteNotification(remoteId);
    }
    await localDataSource.deleteNotification(id);
  }

  @override
  Future<void> clearUserNotifications(String userId) {
    return localDataSource.clearUserNotifications(userId);
  }

  Future<void> _refreshRemote(String userId) async {
    final remote = remoteDataSource;
    if (remote == null) return;
    final notifications = await remote.getNotifications();
    final scopedNotifications = notifications
        .where((notification) => notification.userId == userId)
        .toList();
    await localDataSource.replaceNotifications(userId, scopedNotifications);
  }
}
