import '../../domain/entities/profile_stats_entity.dart';

class ProfileStatsModel {
  final int friendCount;
  final int activityCount;
  final int currentStreak;
  final int longestStreak;

  const ProfileStatsModel({
    required this.friendCount,
    required this.activityCount,
    required this.currentStreak,
    required this.longestStreak,
  });

  factory ProfileStatsModel.fromJson(Map<String, dynamic> json) {
    return ProfileStatsModel(
      friendCount: (json['friendCount'] as num?)?.toInt() ?? 0,
      activityCount: (json['activityCount'] as num?)?.toInt() ?? 0,
      currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
      longestStreak: (json['longestStreak'] as num?)?.toInt() ?? 0,
    );
  }

  ProfileStatsEntity toEntity() {
    return ProfileStatsEntity(
      friendCount: friendCount,
      activityCount: activityCount,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
    );
  }
}
