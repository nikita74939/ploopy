import '../entities/notification_entity.dart';

abstract class NotificationRepository {
  Future<List<NotificationEntity>> getAllNotifications();
  Future<List<NotificationEntity>> getUnreadNotifications();
  Future<void> addNotification(NotificationEntity notification);
  Future<void> markAsRead(int id);
  Future<void> markAllAsRead();
  Future<int> getUnreadCount();
  Future<void> deleteNotification(int id);
}
