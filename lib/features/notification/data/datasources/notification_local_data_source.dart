import 'package:isar/isar.dart';
import '../models/notification_model.dart';

abstract class NotificationLocalDataSource {
  Future<List<NotificationModel>> getAllNotifications();
  Future<List<NotificationModel>> getUnreadNotifications();
  Future<void> addNotification(NotificationModel notification);
  Future<void> markAsRead(int id);
  Future<void> markAllAsRead();
  Future<int> getUnreadCount();
  Future<void> deleteNotification(int id);
}

class NotificationLocalDataSourceImpl implements NotificationLocalDataSource {
  final Isar isar;

  NotificationLocalDataSourceImpl({required this.isar});

  @override
  Future<List<NotificationModel>> getAllNotifications() async {
    return await isar.notificationModels
        .where()
        .sortByCreatedAtDesc()
        .findAll();
  }

  @override
  Future<List<NotificationModel>> getUnreadNotifications() async {
    return await isar.notificationModels
        .filter()
        .isReadEqualTo(false)
        .sortByCreatedAtDesc()
        .findAll();
  }

  @override
  Future<void> addNotification(NotificationModel notification) async {
    await isar.writeTxn(() async {
      await isar.notificationModels.put(notification);
    });
  }

  @override
  Future<void> markAsRead(int id) async {
    final notification = await isar.notificationModels.get(id);
    if (notification != null) {
      notification.isRead = true;
      await isar.writeTxn(() async {
        await isar.notificationModels.put(notification);
      });
    }
  }

  @override
  Future<void> markAllAsRead() async {
    await isar.writeTxn(() async {
      final notifications = await isar.notificationModels
          .filter()
          .isReadEqualTo(false)
          .findAll();
      for (final notification in notifications) {
        notification.isRead = true;
        await isar.notificationModels.put(notification);
      }
    });
  }

  @override
  Future<int> getUnreadCount() async {
    return await isar.notificationModels.filter().isReadEqualTo(false).count();
  }

  @override
  Future<void> deleteNotification(int id) async {
    await isar.writeTxn(() async {
      await isar.notificationModels.delete(id);
    });
  }
}
