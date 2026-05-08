import 'package:isar/isar.dart';

part 'notification_model.g.dart';

@collection
class NotificationModel {
  Id id = Isar.autoIncrement;

  late String title;
  late String description;
  late String tag; // social, study, task, schedule
  String? iconName;
  String? senderId;
  String? relatedId;
  bool isRead = false;
  late DateTime createdAt;
  late String userId;

  NotificationModel();

  factory NotificationModel.create({
    required String title,
    required String description,
    required String tag,
    String? iconName,
    String? senderId,
    String? relatedId,
    required String userId,
  }) {
    return NotificationModel()
      ..title = title
      ..description = description
      ..tag = tag
      ..iconName = iconName
      ..senderId = senderId
      ..relatedId = relatedId
      ..isRead = false
      ..createdAt = DateTime.now()
      ..userId = userId;
  }
}
