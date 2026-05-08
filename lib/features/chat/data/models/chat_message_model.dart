import '../../domain/entities/chat_message_entity.dart';

/// Merepresentasikan baris dari tabel `chat_messages` di Supabase.
///
/// Schema Supabase:
///   id          uuid PK
///   sender_id   uuid FK → auth.users
///   receiver_id uuid FK → auth.users
///   content     text
///   is_read     boolean default false
///   sent_at     timestamptz default now()
class ChatMessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final bool isRead;
  final DateTime sentAt;

  const ChatMessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.isRead,
    required this.sentAt,
  });

  /// Untuk insert ke Supabase — id tidak disertakan (auto-generated)
  factory ChatMessageModel.create({
    required String senderId,
    required String receiverId,
    required String content,
  }) {
    return ChatMessageModel(
      id: '', // akan di-generate Supabase
      senderId: senderId,
      receiverId: receiverId,
      content: content,
      isRead: false,
      sentAt: DateTime.now(),
    );
  }

  factory ChatMessageModel.fromJson(Map<String, dynamic> j) {
    return ChatMessageModel(
      id: j['id'] as String,
      senderId: j['sender_id'] as String,
      receiverId: j['receiver_id'] as String,
      content: j['content'] as String,
      isRead: j['is_read'] as bool? ?? false,
      sentAt: DateTime.parse(j['sent_at'] as String),
    );
  }

  /// Untuk insert — tidak menyertakan `id` agar Supabase auto-generate
  Map<String, dynamic> toInsertJson() => {
        'sender_id': senderId,
        'receiver_id': receiverId,
        'content': content,
        'is_read': isRead,
        'sent_at': sentAt.toIso8601String(),
      };

  ChatMessageEntity toEntity() => ChatMessageEntity(
        id: id,
        senderId: senderId,
        receiverId: receiverId,
        content: content,
        isRead: isRead,
        sentAt: sentAt,
      );
}