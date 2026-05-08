import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../auth/data/models/user_model.dart';
import '../../data/models/achievement_supabase_model.dart';
import '../../data/models/app_settings_model.dart';
import '../../data/models/friendship_model.dart';
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
  final UserModel user;
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
  final AppSettingsModel settings;
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
  final UserModel user;
  final List<AchievementSupabaseModel> achievements;
  final List<UserAchievementSupabaseModel> userAchievements;
  final List<FriendshipModel> friends;
  final StreakModel streak;
  final AppSettingsModel settings;

  ProfileLoaded({
    required this.user,
    required this.achievements,
    required this.userAchievements,
    required this.friends,
    required this.streak,
    required this.settings,
  });

  @override
  List<Object?> get props =>
      [user, achievements, userAchievements, friends, streak, settings];

  ProfileLoaded copyWith({
    UserModel? user,
    List<AchievementSupabaseModel>? achievements,
    List<UserAchievementSupabaseModel>? userAchievements,
    List<FriendshipModel>? friends,
    StreakModel? streak,
    AppSettingsModel? settings,
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
  final AppSettingsModel settings;
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
    emit(ProfileLoading());
    try {
      final results = await Future.wait([
        repository.getUserById(event.userId),
        repository.getAllAchievements(),
        repository.getUserAchievements(event.userId),
        repository.getFriends(event.userId),
        repository.getStreak(event.userId),
        repository.getAppSettings(event.userId),
      ]);

      final user = results[0] as UserModel?;
      if (user == null) {
        emit(ProfileError(message: 'User tidak ditemukan'));
        return;
      }

      emit(ProfileLoaded(
        user: user,
        achievements: results[1] as List<AchievementSupabaseModel>,
        userAchievements: results[2] as List<UserAchievementSupabaseModel>,
        friends: results[3] as List<FriendshipModel>,
        streak: results[4] as StreakModel,
        settings: results[5] as AppSettingsModel,
      ));
    } catch (e) {
      emit(ProfileError(message: e.toString()));
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
      add(LoadProfile(userId: event.user.userId));
    } catch (e) {
      // Kembalikan state sebelumnya jika ada error
      if (currentState is ProfileLoaded) emit(currentState);
      emit(ProfileError(message: e.toString()));
    }
  }

  Future<void> _onLoadAchievements(
    LoadAchievements event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      final achievements = await repository.getAllAchievements();
      final userAchievements =
          await repository.getUserAchievements(event.userId);
      if (state is ProfileLoaded) {
        emit((state as ProfileLoaded).copyWith(
          achievements: achievements,
          userAchievements: userAchievements,
        ));
      }
    } catch (e) {
      emit(ProfileError(message: e.toString()));
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
      emit(ProfileError(message: e.toString()));
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
      emit(ProfileError(message: e.toString()));
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
      emit(ProfileError(message: e.toString()));
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
      emit(ProfileError(message: e.toString()));
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
      emit(ProfileError(message: e.toString()));
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
      emit(ProfileError(message: e.toString()));
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
      emit(ProfileError(message: e.toString()));
    }
  }
}