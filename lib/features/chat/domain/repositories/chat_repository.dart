import '../../domain/entities/chat_message_entity.dart';
import '../../domain/entities/chat_room_entity.dart';

abstract class ChatRepository {
  Future<List<ChatRoomEntity>> getChatRooms(String userId);
  Future<List<ChatMessageEntity>> getMessages(String user1Id, String user2Id);
  Future<void> sendMessage({
    required String senderId,
    required String receiverId,
    required String content,
  });
  Future<void> markMessagesAsRead(String senderId, String receiverId);
  Future<ChatRoomEntity?> getChatRoom(String user1Id, String user2Id);
  Future<void> ensureChatRoomExists(String user1Id, String user2Id);
  Stream<List<ChatMessageEntity>> watchMessages(String user1Id, String user2Id);
  Stream<List<ChatRoomEntity>> watchChatRooms(String userId);
}