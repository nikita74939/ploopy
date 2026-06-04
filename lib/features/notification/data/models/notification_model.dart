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

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final remoteId = json['id'].toString();
    return NotificationModel()
      ..id = _stableId(remoteId)
      ..title = json['title']?.toString() ?? ''
      ..description = json['description']?.toString() ?? ''
      ..tag = json['tag']?.toString() ?? 'general'
      ..senderId = remoteId
      ..relatedId = json['ref_id']?.toString()
      ..iconName = json['ref_type']?.toString()
      ..isRead = (json['is_read'] as bool?) ?? false
      ..createdAt = DateTime.parse(json['created_at'].toString())
      ..userId = json['user_id']?.toString() ?? '';
  }
}

int _stableId(String value) {
  var hash = 0x811c9dc5;
  for (final code in value.codeUnits) {
    hash ^= code;
    hash = (hash * 0x01000193) & 0x7fffffff;
  }
  return hash;
}
