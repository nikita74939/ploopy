import '../entities/notification_entity.dart';

abstract class NotificationRepository {
  Future<List<NotificationEntity>> getAllNotifications(String userId);
  Future<List<NotificationEntity>> getUnreadNotifications(String userId);
  Future<void> addNotification(NotificationEntity notification);
  Future<void> markAsRead(int id);
  Future<void> markAllAsRead(String userId);
  Future<int> getUnreadCount(String userId);
  Future<void> deleteNotification(int id);
  Future<void> clearUserNotifications(String userId);
}
