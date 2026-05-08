import 'package:equatable/equatable.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../../domain/entities/chat_room_entity.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatRoomsLoaded extends ChatState {
  final List<ChatRoomEntity> rooms;
  const ChatRoomsLoaded(this.rooms);

  @override
  List<Object?> get props => [rooms];
}

class MessagesLoaded extends ChatState {
  final List<ChatMessageEntity> messages;
  final bool isSending;
  const MessagesLoaded(this.messages, {this.isSending = false});

  @override
  List<Object?> get props => [messages, isSending];
}

class MessageSent extends ChatState {}

class ChatError extends ChatState {
  final String message;
  const ChatError(this.message);

  @override
  List<Object?> get props => [message];
}

class ChatOffline extends ChatState {
  final String message;
  const ChatOffline(this.message);

  @override
  List<Object?> get props => [message];
}