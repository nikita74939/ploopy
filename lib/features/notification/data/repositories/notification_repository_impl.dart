// lib/features/notification/data/repositories/notification_repository_impl.dart
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_local_data_source.dart';
import '../datasources/notification_remote_data_source.dart';
import '../models/notification_model.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationLocalDataSource localDataSource;
  final NotificationRemoteDataSource? remoteDataSource;

  NotificationRepositoryImpl({
    required this.localDataSource,
    this.remoteDataSource,
  });

  @override
  Future<List<NotificationModel>> getAllNotifications() async {
    await _refreshRemote();
    return await localDataSource.getAllNotifications();
  }

  @override
  Future<List<NotificationModel>> getUnreadNotifications() async {
    return await localDataSource.getUnreadNotifications();
  }

  @override
  Future<void> addNotification(NotificationModel notification) async {
    await localDataSource.addNotification(notification);
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
  Future<void> markAllAsRead() async {
    await remoteDataSource?.markAllAsRead();
    await localDataSource.markAllAsRead();
  }

  @override
  Future<int> getUnreadCount() async {
    return await localDataSource.getUnreadCount();
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

  Future<void> _refreshRemote() async {
    final remote = remoteDataSource;
    if (remote == null) return;
    final notifications = await remote.getNotifications();
    await localDataSource.replaceNotifications(notifications);
  }
}
