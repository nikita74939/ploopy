// lib/features/notification/data/repositories/notification_repository_impl.dart
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_local_data_source.dart';
import '../models/notification_model.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationLocalDataSource localDataSource;

  NotificationRepositoryImpl({required this.localDataSource});

  @override
  Future<List<NotificationModel>> getAllNotifications() async {
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
    await localDataSource.markAsRead(id);
  }

  @override
  Future<void> markAllAsRead() async {
    await localDataSource.markAllAsRead();
  }

  @override
  Future<int> getUnreadCount() async {
    return await localDataSource.getUnreadCount();
  }

  @override
  Future<void> deleteNotification(int id) async {
    await localDataSource.deleteNotification(id);
  }
}
