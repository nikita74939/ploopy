import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/entities/notification_entity.dart';

// Events
abstract class NotificationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadNotifications extends NotificationEvent {}

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

  NotificationLoaded({
    required this.allNotifications,
    required this.unreadNotifications,
    required this.unreadCount,
  });

  @override
  List<Object?> get props => [
    allNotifications,
    unreadNotifications,
    unreadCount,
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

  NotificationBloc({required this.repository}) : super(NotificationInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<MarkNotificationAsRead>(_onMarkNotificationAsRead);
    on<MarkAllNotificationsAsRead>(_onMarkAllNotificationsAsRead);
    on<DeleteNotification>(_onDeleteNotification);
  }

  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    try {
      final all = await repository.getAllNotifications();
      final unread = all
          .where((notification) => !notification.isRead)
          .toList(growable: false);
      emit(
        NotificationLoaded(
          allNotifications: all,
          unreadNotifications: unread,
          unreadCount: unread.length,
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
      await repository.markAllAsRead();
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
}
