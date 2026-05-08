import '../../domain/entities/chat_message_entity.dart';
import '../../domain/entities/chat_room_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_datasource.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<List<ChatRoomEntity>> getChatRooms(String userId) async {
    try {
      final remoteRooms = await remoteDataSource.getChatRooms(userId);
      return remoteRooms.map((m) => m.toEntity()).toList();
    } catch (e) {
      // Handle error atau lempar exception sesuai arsitektur kamu
      throw Exception('Failed to get chat rooms: $e');
    }
  }

  @override
  Future<List<ChatMessageEntity>> getMessages(
      String user1Id, String user2Id) async {
    try {
      final remoteMessages =
          await remoteDataSource.getMessages(user1Id, user2Id);
      return remoteMessages.map((m) => m.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get messages: $e');
    }
  }

  @override
  Future<void> sendMessage({
    required String senderId,
    required String receiverId,
    required String content,
  }) async {
    try {
      // Langsung teruskan parameter String ke remote datasource
      await remoteDataSource.sendMessage(
        senderId: senderId,
        receiverId: receiverId,
        content: content,
      );
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  @override
  Future<void> markMessagesAsRead(
      String senderId, String receiverId) async {
    try {
      await remoteDataSource.markMessagesAsRead(senderId, receiverId);
    } catch (_) {
      // Abaikan error jika gagal update read status, atau tangani sesuai kebutuhan
    }
  }

  @override
  Future<ChatRoomEntity?> getChatRoom(
      String user1Id, String user2Id) async {
    try {
      // Ambil semua room dari user1Id
      final rooms = await remoteDataSource.getChatRooms(user1Id);
      
      // Cari room yang memiliki user2Id sebagai lawan chat-nya
      final room = rooms.where((r) => 
        (r.userId1 == user2Id || r.userId2 == user2Id)
      ).firstOrNull;

      return room?.toEntity();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> ensureChatRoomExists(
      String user1Id, String user2Id) async {
    try {
      await remoteDataSource.ensureChatRoomExists(user1Id, user2Id);
    } catch (e) {
      throw Exception('Failed to ensure chat room exists: $e');
    }
  }

  @override
  Stream<List<ChatMessageEntity>> watchMessages(
      String user1Id, String user2Id) {
    return remoteDataSource.watchMessages(user1Id, user2Id).map(
        (list) => list.map((m) => m.toEntity()).toList());
  }

  @override
  Stream<List<ChatRoomEntity>> watchChatRooms(String userId) {
    return remoteDataSource
        .watchChatRooms(userId)
        .map((list) => list.map((m) => m.toEntity()).toList());
  }
}