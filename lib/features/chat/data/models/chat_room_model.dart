import '../../domain/entities/chat_room_entity.dart';
import '../../domain/entities/chat_message_entity.dart';

/// Merepresentasikan baris dari view `chat_rooms_with_users` di Supabase.
///
/// View ini meng-join tabel `chat_rooms` dengan `profiles`
/// sehingga tersedia: user1_name, user1_avatar, user2_name, user2_avatar.
///
/// Schema tabel `chat_rooms`:
///   id                    uuid PK
///   user1_id              uuid FK → auth.users
///   user2_id              uuid FK → auth.users
///   last_message_content  text nullable
///   last_message_sender_id uuid nullable
///   last_message_at       timestamptz nullable
///
/// Field dari join `profiles` (sesuai UserModel):
///   user1_name, user1_avatar  ← profiles.name, profiles.avatar_url
///   user2_name, user2_avatar
///   unread_count (dihitung via view/RPC)
class ChatRoomModel {
  final String id;
  final String userId1;
  final String userId2;
  final String otherUserId;
  final String otherUserName;
  final String? otherUserAvatar;
  final String? lastMessageContent;
  final String? lastMessageSenderId;
  final DateTime? lastMessageAt;
  final int unreadCount;

  const ChatRoomModel({
    required this.id,
    required this.userId1,
    required this.userId2,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserAvatar,
    this.lastMessageContent,
    this.lastMessageSenderId,
    this.lastMessageAt,
    this.unreadCount = 0,
  });

  factory ChatRoomModel.fromJson(
    Map<String, dynamic> j,
    String currentUserId,
  ) {
    final isUser1 = j['user1_id'] == currentUserId;

    // Nama & avatar mengikuti kolom `name` & `avatar_url` di tabel profiles
    // (sesuai UserModel: field `name` dan `avatarUrl`)
    final otherUserId =
        isUser1 ? j['user2_id'] as String : j['user1_id'] as String;
    final otherUserName = isUser1
        ? (j['user2_name'] as String? ?? 'Unknown')
        : (j['user1_name'] as String? ?? 'Unknown');
    final otherUserAvatar = isUser1
        ? j['user2_avatar'] as String?
        : j['user1_avatar'] as String?;

    return ChatRoomModel(
      id: j['id'] as String,
      userId1: j['user1_id'] as String,
      userId2: j['user2_id'] as String,
      otherUserId: otherUserId,
      otherUserName: otherUserName,
      otherUserAvatar: otherUserAvatar,
      lastMessageContent: j['last_message_content'] as String?,
      lastMessageSenderId: j['last_message_sender_id'] as String?,
      lastMessageAt: j['last_message_at'] != null
          ? DateTime.parse(j['last_message_at'] as String)
          : null,
      unreadCount: (j['unread_count'] as num?)?.toInt() ?? 0,
    );
  }

  ChatRoomEntity toEntity() {
    ChatMessageEntity? lastMsg;
    if (lastMessageContent != null && lastMessageSenderId != null) {
      lastMsg = ChatMessageEntity(
        id: '',
        senderId: lastMessageSenderId!,
        receiverId: otherUserId,
        content: lastMessageContent!,
        isRead: true,
        sentAt: lastMessageAt ?? DateTime.now(),
      );
    }

    return ChatRoomEntity(
      id: id,
      userId1: userId1,
      userId2: userId2,
      otherUserId: otherUserId,
      otherUserName: otherUserName,
      otherUserAvatar: otherUserAvatar,
      lastMessage: lastMsg,
      lastMessageAt: lastMessageAt,
      unreadCount: unreadCount,
    );
  }
}