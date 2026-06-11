import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/entities/notification_entity.dart';

// Events
abstract class NotificationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadNotifications extends NotificationEvent {
  final String? userId;

  LoadNotifications({this.userId});

  @override
  List<Object?> get props => [userId];
}

class MarkNotificationAsRead extends NotificationEvent {
  final int id;

  MarkNotificationAsRead({required this.id});

  @override
  List<Object?> get props => [id];
}

class MarkAllNotificationsAsRead extends NotificationEvent {}

class DeleteNotification extends NotificationEvent {
  final int id;

  DeleteNotification({required this.id});

  @override
  List<Object?> get props => [id];
}

class ClearNotifications extends NotificationEvent {}

// States
abstract class NotificationState extends Equatable {
  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<NotificationEntity> allNotifications;
  final List<NotificationEntity> unreadNotifications;
  final int unreadCount;
  final String userId;

  NotificationLoaded({
    required this.allNotifications,
    required this.unreadNotifications,
    required this.unreadCount,
    required this.userId,
  });

  @override
  List<Object?> get props => [
    allNotifications,
    unreadNotifications,
    unreadCount,
    userId,
  ];
}

class NotificationError extends NotificationState {
  final String message;

  NotificationError({required this.message});

  @override
  List<Object?> get props => [message];
}

// BLoC
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository repository;
  String? _currentUserId;

  NotificationBloc({required this.repository}) : super(NotificationInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<MarkNotificationAsRead>(_onMarkNotificationAsRead);
    on<MarkAllNotificationsAsRead>(_onMarkAllNotificationsAsRead);
    on<DeleteNotification>(_onDeleteNotification);
    on<ClearNotifications>(_onClearNotifications);
  }

  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    final userId = event.userId ?? _currentUserId;
    if (userId == null || userId.isEmpty) {
      emit(NotificationInitial());
      return;
    }

    _currentUserId = userId;
    emit(NotificationLoading());
    try {
      final all = await repository.getAllNotifications(userId);
      final unread = all
          .where((notification) => !notification.isRead)
          .toList(growable: false);
      emit(
        NotificationLoaded(
          allNotifications: all,
          unreadNotifications: unread,
          unreadCount: unread.length,
          userId: userId,
        ),
      );
    } catch (e) {
      emit(NotificationError(message: e.toString()));
    }
  }

  Future<void> _onMarkNotificationAsRead(
    MarkNotificationAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await repository.markAsRead(event.id);
      add(LoadNotifications());
    } catch (e) {
      emit(NotificationError(message: e.toString()));
    }
  }

  Future<void> _onMarkAllNotificationsAsRead(
    MarkAllNotificationsAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      final userId = _currentUserId;
      if (userId == null || userId.isEmpty) return;
      await repository.markAllAsRead(userId);
      add(LoadNotifications());
    } catch (e) {
      emit(NotificationError(message: e.toString()));
    }
  }

  Future<void> _onDeleteNotification(
    DeleteNotification event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await repository.deleteNotification(event.id);
      add(LoadNotifications());
    } catch (e) {
      emit(NotificationError(message: e.toString()));
    }
  }

  Future<void> _onClearNotifications(
    ClearNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    final userId = _currentUserId;
    _currentUserId = null;
    if (userId != null && userId.isNotEmpty) {
      await repository.clearUserNotifications(userId);
    }
    emit(NotificationInitial());
  }
}
