import 'package:isar/isar.dart';
import '../models/notification_model.dart';

abstract class NotificationLocalDataSource {
  Future<List<NotificationModel>> getAllNotifications(String userId);
  Future<List<NotificationModel>> getUnreadNotifications(String userId);
  Future<void> addNotification(NotificationModel notification);
  Future<void> replaceNotifications(
    String userId,
    List<NotificationModel> notifications,
  );
  Future<NotificationModel?> getNotificationById(int id);
  Future<void> markAsRead(int id);
  Future<void> markAllAsRead(String userId);
  Future<int> getUnreadCount(String userId);
  Future<void> deleteNotification(int id);
  Future<void> clearUserNotifications(String userId);
}

class NotificationLocalDataSourceImpl implements NotificationLocalDataSource {
  final Isar isar;

  NotificationLocalDataSourceImpl({required this.isar});

  @override
  Future<List<NotificationModel>> getAllNotifications(String userId) async {
    return await isar.notificationModels
        .filter()
        .userIdEqualTo(userId)
        .createdAtLessThan(DateTime.now(), include: true)
        .sortByCreatedAtDesc()
        .findAll();
  }

  @override
  Future<List<NotificationModel>> getUnreadNotifications(String userId) async {
    return await isar.notificationModels
        .filter()
        .userIdEqualTo(userId)
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
    String userId,
    List<NotificationModel> notifications,
  ) async {
    await isar.writeTxn(() async {
      final localOnly = await isar.notificationModels.where().findAll();
      final localNotifications = localOnly
          .where(
            (notification) =>
                notification.userId == userId && notification.senderId == null,
          )
          .toList();
      final currentUserNotifications = localOnly
          .where((notification) => notification.userId == userId)
          .map((notification) => notification.id)
          .toList();
      await isar.notificationModels.deleteAll(currentUserNotifications);
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
  Future<void> markAllAsRead(String userId) async {
    await isar.writeTxn(() async {
      final notifications = await isar.notificationModels
          .filter()
          .userIdEqualTo(userId)
          .isReadEqualTo(false)
          .findAll();
      for (final notification in notifications) {
        notification.isRead = true;
        await isar.notificationModels.put(notification);
      }
    });
  }

  @override
  Future<int> getUnreadCount(String userId) async {
    return await isar.notificationModels
        .filter()
        .userIdEqualTo(userId)
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

  @override
  Future<void> clearUserNotifications(String userId) async {
    await isar.writeTxn(() async {
      final ids = await isar.notificationModels
          .filter()
          .userIdEqualTo(userId)
          .idProperty()
          .findAll();
      await isar.notificationModels.deleteAll(ids);
    });
  }
}
