import 'package:equatable/equatable.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../../domain/entities/chat_room_entity.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class LoadChatRoomsEvent extends ChatEvent {
  final String userId;
  const LoadChatRoomsEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class WatchChatRoomsEvent extends ChatEvent {
  final String userId;
  const WatchChatRoomsEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class LoadMessagesEvent extends ChatEvent {
  final String user1Id;
  final String user2Id;
  const LoadMessagesEvent(this.user1Id, this.user2Id);

  @override
  List<Object?> get props => [user1Id, user2Id];
}

class WatchMessagesEvent extends ChatEvent {
  final String user1Id;
  final String user2Id;
  const WatchMessagesEvent(this.user1Id, this.user2Id);

  @override
  List<Object?> get props => [user1Id, user2Id];
}

class SendMessageEvent extends ChatEvent {
  final String senderId;
  final String receiverId;
  final String content;
  const SendMessageEvent({
    required this.senderId,
    required this.receiverId,
    required this.content,
  });

  @override
  List<Object?> get props => [senderId, receiverId, content];
}

class MarkMessagesReadEvent extends ChatEvent {
  final String senderId;
  final String receiverId;
  const MarkMessagesReadEvent(this.senderId, this.receiverId);

  @override
  List<Object?> get props => [senderId, receiverId];
}

// Internal events untuk update dari stream
class ChatRoomsUpdatedEvent extends ChatEvent {
  final List<ChatRoomEntity> rooms;
  const ChatRoomsUpdatedEvent(this.rooms);

  @override
  List<Object?> get props => [rooms];
}

class MessagesUpdatedEvent extends ChatEvent {
  final List<ChatMessageEntity> messages;
  const MessagesUpdatedEvent(this.messages);

  @override
  List<Object?> get props => [messages];
}