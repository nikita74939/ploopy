import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../../features/auth/data/models/user_model.dart';
import '../../features/schedule/data/models/schedule_model.dart';
import '../../features/task/data/models/task_model.dart';
import '../../features/study/domain/models/study_session_model.dart';
import '../../features/notification/data/models/notification_model.dart';
import '../../features/profile/data/models/achievement_model.dart';

class IsarService {
  static Isar? _isar;

  static Future<Isar> getInstance() async {
    if (_isar != null) return _isar!;

    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [
        UserModelSchema,
        ScheduleModelSchema,
        TaskModelSchema,
        StudySessionModelSchema,
        NotificationModelSchema,
        AchievementModelSchema,
        UserAchievementModelSchema,
      ],
      directory: dir.path,
    );

    return _isar!;
  }

  static Future<void> close() async {
    await _isar?.close();
    _isar = null;
  }
}