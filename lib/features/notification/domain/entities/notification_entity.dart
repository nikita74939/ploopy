class NotificationEntity {
  final int id;
  final String userId;
  final String title;
  final String description;
  final String tag; // social | study | task | schedule
  final bool isRead;
  final DateTime createdAt;
  final String? refId;
  final String? refType;
  final String? senderUserId;

  const NotificationEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.tag,
    required this.isRead,
    required this.createdAt,
    this.refId,
    this.refType,
    this.senderUserId,
  });
}
