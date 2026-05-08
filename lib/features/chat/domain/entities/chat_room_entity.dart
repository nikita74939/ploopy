import 'chat_message_entity.dart';

class ChatRoomEntity {
  final String id; // UUID dari Supabase
  final String userId1;
  final String userId2;

  // Info user lawan bicara (joined dari profiles)
  final String otherUserId;
  final String otherUserName;
  final String? otherUserAvatar;

  final ChatMessageEntity? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;

  const ChatRoomEntity({
    required this.id,
    required this.userId1,
    required this.userId2,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserAvatar,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCount = 0,
  });
}