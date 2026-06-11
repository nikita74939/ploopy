import 'package:isar/isar.dart';
import '../models/notification_model.dart';

abstract class NotificationLocalDataSource {
  Future<List<NotificationModel>> getAllNotifications();
  Future<List<NotificationModel>> getUnreadNotifications();
  Future<void> addNotification(NotificationModel notification);
  Future<void> replaceNotifications(List<NotificationModel> notifications);
  Future<NotificationModel?> getNotificationById(int id);
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
        .filter()
        .createdAtLessThan(DateTime.now(), include: true)
        .sortByCreatedAtDesc()
        .findAll();
  }

  @override
  Future<List<NotificationModel>> getUnreadNotifications() async {
    return await isar.notificationModels
        .filter()
        .createdAtLessThan(DateTime.now(), include: true)
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
  Future<void> replaceNotifications(
    List<NotificationModel> notifications,
  ) async {
    await isar.writeTxn(() async {
      final localOnly = await isar.notificationModels.where().findAll();
      final localNotifications = localOnly
          .where((notification) => notification.senderId == null)
          .toList();
      await isar.notificationModels.clear();
      await isar.notificationModels.putAll([
        ...notifications,
        ...localNotifications,
      ]);
    });
  }

  @override
  Future<NotificationModel?> getNotificationById(int id) {
    return isar.notificationModels.get(id);
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
    return await isar.notificationModels
        .filter()
        .createdAtLessThan(DateTime.now(), include: true)
        .isReadEqualTo(false)
        .count();
  }

  @override
  Future<void> deleteNotification(int id) async {
    await isar.writeTxn(() async {
      await isar.notificationModels.delete(id);
    });
  }
}
