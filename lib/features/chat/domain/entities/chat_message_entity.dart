class ChatMessageEntity {
  final String id; // UUID dari Supabase
  final String senderId;
  final String receiverId;
  final String content;
  final bool isRead;
  final DateTime sentAt;

  const ChatMessageEntity({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.isRead,
    required this.sentAt,
  });
}