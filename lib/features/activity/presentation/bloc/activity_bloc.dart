import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/network/auth_session_guard.dart';
import '../../domain/repositories/activity_repository.dart';
import '../../data/models/activity_model.dart';
import '../../data/models/activity_comment_model.dart';

// ─────────────────────────────────────────
// Events
// ─────────────────────────────────────────

abstract class ActivityEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadActivities extends ActivityEvent {}

class LoadActivitiesByUser extends ActivityEvent {
  final String userId;

  LoadActivitiesByUser({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class CreateActivity extends ActivityEvent {
  final String userId;
  final String text;
  final String? location;
  final String? achievementId;
  final List<String>? imageUrls;

  CreateActivity({
    required this.userId,
    required this.text,
    this.location,
    this.achievementId,
    this.imageUrls,
  });

  @override
  List<Object?> get props => [userId, text, location, achievementId, imageUrls];
}

class DeleteActivity extends ActivityEvent {
  final String id;

  DeleteActivity({required this.id});

  @override
  List<Object?> get props => [id];
}

class ToggleLike extends ActivityEvent {
  final String activityId;
  final String userId;

  ToggleLike({required this.activityId, required this.userId});

  @override
  List<Object?> get props => [activityId, userId];
}

class LoadComments extends ActivityEvent {
  final String activityId;

  LoadComments({required this.activityId});

  @override
  List<Object?> get props => [activityId];
}

class AddComment extends ActivityEvent {
  final String activityId;
  final String userId;
  final String content;

  AddComment({
    required this.activityId,
    required this.userId,
    required this.content,
  });

  @override
  List<Object?> get props => [activityId, userId, content];
}

// ─────────────────────────────────────────
// States
// ─────────────────────────────────────────

abstract class ActivityState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ActivityInitial extends ActivityState {}

class ActivityLoading extends ActivityState {}

class ActivitiesLoaded extends ActivityState {
  final List<ActivityModel> activities;

  ActivitiesLoaded({required this.activities});

  @override
  List<Object?> get props => [activities];
}

class CommentsLoaded extends ActivityState {
  final List<ActivityCommentModel> comments;

  CommentsLoaded({required this.comments});

  @override
  List<Object?> get props => [comments];
}

class ActivityOperationSuccess extends ActivityState {
  final String message;

  ActivityOperationSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class ActivityError extends ActivityState {
  final String message;

  ActivityError({required this.message});

  @override
  List<Object?> get props => [message];
}

// ─────────────────────────────────────────
// BLoC
// ─────────────────────────────────────────

class ActivityBloc extends Bloc<ActivityEvent, ActivityState> {
  final ActivityRepository repository;

  ActivityBloc({required this.repository}) : super(ActivityInitial()) {
    on<LoadActivities>(_onLoadActivities);
    on<LoadActivitiesByUser>(_onLoadActivitiesByUser);
    on<CreateActivity>(_onCreateActivity);
    on<DeleteActivity>(_onDeleteActivity);
    on<ToggleLike>(_onToggleLike);
    on<LoadComments>(_onLoadComments);
    on<AddComment>(_onAddComment);
  }

  Future<void> _onLoadActivities(
    LoadActivities event,
    Emitter<ActivityState> emit,
  ) async {
    emit(ActivityLoading());
    try {
      final activities = await repository.getAllActivities();
      emit(ActivitiesLoaded(activities: activities));
    } catch (e) {
      emit(ActivityError(message: e.toString()));
    }
  }

  Future<void> _onLoadActivitiesByUser(
    LoadActivitiesByUser event,
    Emitter<ActivityState> emit,
  ) async {
    emit(ActivityLoading());
    try {
      final activities = await repository.getActivitiesByUser(event.userId);
      emit(ActivitiesLoaded(activities: activities));
    } catch (e) {
      if (_handleExpiredSession(e)) return;
      emit(ActivityError(message: e.toString()));
    }
  }

  Future<void> _onCreateActivity(
    CreateActivity event,
    Emitter<ActivityState> emit,
  ) async {
    emit(ActivityLoading());
    try {
      await repository.createActivity(
        userId: event.userId,
        text: event.text,
        location: event.location,
        achievementId: event.achievementId,
        imageUrls: event.imageUrls,
      );
      emit(ActivityOperationSuccess(message: 'Activity posted successfully'));
      add(LoadActivities());
    } catch (e) {
      if (_handleExpiredSession(e)) return;
      emit(ActivityError(message: e.toString()));
    }
  }

  Future<void> _onDeleteActivity(
    DeleteActivity event,
    Emitter<ActivityState> emit,
  ) async {
    emit(ActivityLoading());
    try {
      await repository.deleteActivity(event.id);
      emit(ActivityOperationSuccess(message: 'Activity deleted'));
      add(LoadActivities());
    } catch (e) {
      if (_handleExpiredSession(e)) return;
      emit(ActivityError(message: e.toString()));
    }
  }

  Future<void> _onToggleLike(
    ToggleLike event,
    Emitter<ActivityState> emit,
  ) async {
    try {
      await repository.toggleLike(event.activityId, event.userId);
      add(LoadActivities());
    } catch (e) {
      if (_handleExpiredSession(e)) return;
      emit(ActivityError(message: e.toString()));
    }
  }

  Future<void> _onLoadComments(
    LoadComments event,
    Emitter<ActivityState> emit,
  ) async {
    try {
      final comments = await repository.getComments(event.activityId);
      emit(CommentsLoaded(comments: comments));
    } catch (e) {
      if (_handleExpiredSession(e)) return;
      emit(ActivityError(message: e.toString()));
    }
  }

  Future<void> _onAddComment(
    AddComment event,
    Emitter<ActivityState> emit,
  ) async {
    try {
      await repository.addComment(
        activityId: event.activityId,
        userId: event.userId,
        content: event.content,
      );
      add(LoadComments(activityId: event.activityId));
    } catch (e) {
      if (_handleExpiredSession(e)) return;
      emit(ActivityError(message: e.toString()));
    }
  }

  bool _handleExpiredSession(Object error) {
    final message = error.toString().toLowerCase();
    final expired =
        message.contains('invalid or expired token') ||
        message.contains('missing bearer token') ||
        message.contains('sesi habis');
    if (expired) AuthSessionGuard.notifyExpired();
    return expired;
  }
}
