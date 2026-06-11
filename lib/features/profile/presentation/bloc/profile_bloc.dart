import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/entities/achievement_entity.dart';
import '../../domain/entities/app_settings_entity.dart';
import '../../domain/entities/friendship_entity.dart';
import '../../domain/entities/streak_entity.dart';
import '../../domain/repositories/profile_repository.dart';

// ─── EVENTS ──────────────────────────────────────────────────────────────────

abstract class ProfileEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadProfile extends ProfileEvent {
  final String userId;
  LoadProfile({required this.userId});
  @override
  List<Object?> get props => [userId];
}

class UpdateProfile extends ProfileEvent {
  final UserEntity user;
  UpdateProfile({required this.user});
  @override
  List<Object?> get props => [user];
}

class LoadAchievements extends ProfileEvent {
  final String userId;
  LoadAchievements({required this.userId});
  @override
  List<Object?> get props => [userId];
}

class UnlockAchievement extends ProfileEvent {
  final String userId;
  final String achievementId;
  UnlockAchievement({required this.userId, required this.achievementId});
  @override
  List<Object?> get props => [userId, achievementId];
}

class LoadFriends extends ProfileEvent {
  final String userId;
  LoadFriends({required this.userId});
  @override
  List<Object?> get props => [userId];
}

class SendFriendRequest extends ProfileEvent {
  final String requesterId;
  final String addresseeId;
  SendFriendRequest({required this.requesterId, required this.addresseeId});
  @override
  List<Object?> get props => [requesterId, addresseeId];
}

class AcceptFriendRequest extends ProfileEvent {
  final String friendshipId;
  final String userId;
  AcceptFriendRequest({required this.friendshipId, required this.userId});
  @override
  List<Object?> get props => [friendshipId, userId];
}

class RemoveFriend extends ProfileEvent {
  final String friendshipId;
  final String userId;
  RemoveFriend({required this.friendshipId, required this.userId});
  @override
  List<Object?> get props => [friendshipId, userId];
}

class LoadAppSettings extends ProfileEvent {
  final String userId;
  LoadAppSettings({required this.userId});
  @override
  List<Object?> get props => [userId];
}

class UpdateAppSettings extends ProfileEvent {
  final ProfileAppSettingsEntity settings;
  UpdateAppSettings({required this.settings});
  @override
  List<Object?> get props => [settings];
}

// ─── STATES ──────────────────────────────────────────────────────────────────

abstract class ProfileState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserEntity user;
  final List<AchievementEntity> achievements;
  final List<UserAchievementEntity> userAchievements;
  final List<ProfileFriendshipEntity> friends;
  final ProfileStreakEntity streak;
  final ProfileAppSettingsEntity settings;

  ProfileLoaded({
    required this.user,
    required this.achievements,
    required this.userAchievements,
    required this.friends,
    required this.streak,
    required this.settings,
  });

  @override
  List<Object?> get props => [
    user,
    achievements,
    userAchievements,
    friends,
    streak,
    settings,
  ];

  ProfileLoaded copyWith({
    UserEntity? user,
    List<AchievementEntity>? achievements,
    List<UserAchievementEntity>? userAchievements,
    List<ProfileFriendshipEntity>? friends,
    ProfileStreakEntity? streak,
    ProfileAppSettingsEntity? settings,
  }) {
    return ProfileLoaded(
      user: user ?? this.user,
      achievements: achievements ?? this.achievements,
      userAchievements: userAchievements ?? this.userAchievements,
      friends: friends ?? this.friends,
      streak: streak ?? this.streak,
      settings: settings ?? this.settings,
    );
  }
}

class ProfileUpdateSuccess extends ProfileState {}

class SettingsLoaded extends ProfileState {
  final ProfileAppSettingsEntity settings;
  SettingsLoaded({required this.settings});
  @override
  List<Object?> get props => [settings];
}

class ProfileError extends ProfileState {
  final String message;
  ProfileError({required this.message});
  @override
  List<Object?> get props => [message];
}

// ─── BLOC ─────────────────────────────────────────────────────────────────────

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository repository;
  String? _loadingUserId;
  String? _loadedUserId;

  ProfileBloc({required this.repository}) : super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateProfile>(_onUpdateProfile);
    on<LoadAchievements>(_onLoadAchievements);
    on<UnlockAchievement>(_onUnlockAchievement);
    on<LoadFriends>(_onLoadFriends);
    on<SendFriendRequest>(_onSendFriendRequest);
    on<AcceptFriendRequest>(_onAcceptFriendRequest);
    on<RemoveFriend>(_onRemoveFriend);
    on<LoadAppSettings>(_onLoadAppSettings);
    on<UpdateAppSettings>(_onUpdateAppSettings);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    if (_loadingUserId == event.userId) return;
    if (state is ProfileLoaded && _loadedUserId == event.userId) return;
    _loadingUserId = event.userId;
    emit(ProfileLoading());
    try {
      final userFuture = repository.getUserById(event.userId);
      final achievementsFuture = repository.getAllAchievements().catchError(
        (_) => <AchievementEntity>[],
      );
      final userAchievementsFuture = repository
          .getUserAchievements(event.userId)
          .catchError((_) => <UserAchievementEntity>[]);
      final friendsFuture = repository
          .getFriends(event.userId)
          .catchError((_) => <ProfileFriendshipEntity>[]);
      final streakFuture = repository
          .getStreak(event.userId)
          .catchError((_) => ProfileStreakEntity.defaultFor(event.userId));
      final settingsFuture = repository
          .getAppSettings(event.userId)
          .catchError((_) => ProfileAppSettingsEntity.defaultFor(event.userId));

      final user = await userFuture;
      if (user == null) {
        emit(ProfileError(message: 'User tidak ditemukan'));
        return;
      }

      emit(
        ProfileLoaded(
          user: user,
          achievements: await achievementsFuture,
          userAchievements: await userAchievementsFuture,
          friends: await friendsFuture,
          streak: await streakFuture,
          settings: await settingsFuture,
        ),
      );
      _loadedUserId = event.userId;
    } catch (e) {
      emit(ProfileError(message: _cleanError(e)));
    } finally {
      _loadingUserId = null;
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfile event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    try {
      await repository.updateUser(event.user);
      // Reload profile agar data segar
      _loadedUserId = null;
      add(LoadProfile(userId: event.user.userId));
    } catch (e) {
      // Kembalikan state sebelumnya jika ada error
      if (currentState is ProfileLoaded) emit(currentState);
      emit(ProfileError(message: _cleanError(e)));
    }
  }

  Future<void> _onLoadAchievements(
    LoadAchievements event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      final achievements = await repository.getAllAchievements();
      final userAchievements = await repository.getUserAchievements(
        event.userId,
      );
      if (state is ProfileLoaded) {
        emit(
          (state as ProfileLoaded).copyWith(
            achievements: achievements,
            userAchievements: userAchievements,
          ),
        );
      }
    } catch (e) {
      emit(ProfileError(message: _cleanError(e)));
    }
  }

  Future<void> _onUnlockAchievement(
    UnlockAchievement event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      await repository.unlockAchievement(event.userId, event.achievementId);
      add(LoadAchievements(userId: event.userId));
    } catch (e) {
      emit(ProfileError(message: _cleanError(e)));
    }
  }

  Future<void> _onLoadFriends(
    LoadFriends event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      final friends = await repository.getFriends(event.userId);
      if (state is ProfileLoaded) {
        emit((state as ProfileLoaded).copyWith(friends: friends));
      }
    } catch (e) {
      emit(ProfileError(message: _cleanError(e)));
    }
  }

  Future<void> _onSendFriendRequest(
    SendFriendRequest event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      await repository.sendFriendRequest(event.requesterId, event.addresseeId);
      add(LoadFriends(userId: event.requesterId));
    } catch (e) {
      emit(ProfileError(message: _cleanError(e)));
    }
  }

  Future<void> _onAcceptFriendRequest(
    AcceptFriendRequest event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      await repository.acceptFriendRequest(event.friendshipId);
      add(LoadFriends(userId: event.userId));
    } catch (e) {
      emit(ProfileError(message: _cleanError(e)));
    }
  }

  Future<void> _onRemoveFriend(
    RemoveFriend event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      await repository.removeFriend(event.friendshipId);
      add(LoadFriends(userId: event.userId));
    } catch (e) {
      emit(ProfileError(message: _cleanError(e)));
    }
  }

  Future<void> _onLoadAppSettings(
    LoadAppSettings event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      final settings = await repository.getAppSettings(event.userId);
      // Update settings di ProfileLoaded jika ada, jika tidak emit SettingsLoaded
      if (state is ProfileLoaded) {
        emit((state as ProfileLoaded).copyWith(settings: settings));
      } else {
        emit(SettingsLoaded(settings: settings));
      }
    } catch (e) {
      emit(ProfileError(message: _cleanError(e)));
    }
  }

  Future<void> _onUpdateAppSettings(
    UpdateAppSettings event,
    Emitter<ProfileState> emit,
  ) async {
    // Simpan state lama untuk optimistic update
    final previousState = state;
    try {
      // Optimistic update: langsung perbarui UI sebelum request selesai
      if (previousState is ProfileLoaded) {
        emit(previousState.copyWith(settings: event.settings));
      }
      await repository.upsertAppSettings(event.settings);
    } catch (e) {
      // Rollback ke state sebelumnya jika gagal
      if (previousState is ProfileLoaded) emit(previousState);
      emit(ProfileError(message: _cleanError(e)));
    }
  }

  String _cleanError(Object e) {
    final message = e.toString();
    final cleaned = message.startsWith('Exception: ')
        ? message.substring(11)
        : message;
    if (cleaned.toLowerCase().contains('internal server error') ||
        cleaned.contains('500')) {
      return 'Server sedang bermasalah. Coba lagi nanti.';
    }
    if (cleaned.toLowerCase().contains('invalid or expired token') ||
        cleaned.toLowerCase().contains('missing bearer token')) {
      return 'Sesi habis. Silakan login lagi.';
    }
    return cleaned.trim().isEmpty ? 'Gagal memuat profil.' : cleaned;
  }
}
