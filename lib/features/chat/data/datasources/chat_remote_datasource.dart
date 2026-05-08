import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/chat_message_model.dart';
import '../models/chat_room_model.dart';

abstract class ChatRemoteDataSource {
  Future<List<ChatRoomModel>> getChatRooms(String userId);
  Future<List<ChatMessageModel>> getMessages(String user1Id, String user2Id);
  Future<ChatMessageModel> sendMessage({
    required String senderId,
    required String receiverId,
    required String content,
  });
  Future<void> markMessagesAsRead(String senderId, String receiverId);
  Future<void> ensureChatRoomExists(String user1Id, String user2Id);
  Stream<List<ChatMessageModel>> watchMessages(String user1Id, String user2Id);
  Stream<List<ChatRoomModel>> watchChatRooms(String userId);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final SupabaseClient supabase;

  ChatRemoteDataSourceImpl({required this.supabase});

  String? get _currentUserId => supabase.auth.currentUser?.id;

  @override
  Future<List<ChatRoomModel>> getChatRooms(String userId) async {
    final data = await supabase
        .from('chat_rooms_with_users')
        .select()
        .or('user1_id.eq.$userId,user2_id.eq.$userId')
        .order('last_message_at', ascending: false);

    return (data as List)
        .map((j) => ChatRoomModel.fromJson(j as Map<String, dynamic>, userId))
        .toList();
  }

  @override
  Future<List<ChatMessageModel>> getMessages(
    String user1Id,
    String user2Id,
  ) async {
    final data = await supabase
        .from('chat_messages')
        .select()
        .or(
          'and(sender_id.eq.$user1Id,receiver_id.eq.$user2Id),'
          'and(sender_id.eq.$user2Id,receiver_id.eq.$user1Id)',
        )
        .order('sent_at', ascending: true);

    return (data as List)
        .map((j) => ChatMessageModel.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ChatMessageModel> sendMessage({
    required String senderId,
    required String receiverId,
    required String content,
  }) async {
    // 1. Pastikan chat room sudah ada
    await ensureChatRoomExists(senderId, receiverId);

    // 2. Insert pesan, Supabase returns row dengan id UUID
    final response = await supabase
        .from('chat_messages')
        .insert({
          'sender_id': senderId,
          'receiver_id': receiverId,
          'content': content,
          'is_read': false,
        })
        .select()
        .single();

    final message = ChatMessageModel.fromJson(response);

    // 3. Update last message di chat_rooms
    await _updateRoomLastMessage(
      senderId: senderId,
      receiverId: receiverId,
      content: content,
      sentAt: message.sentAt,
    );

    return message;
  }

  Future<void> _updateRoomLastMessage({
    required String senderId,
    required String receiverId,
    required String content,
    required DateTime sentAt,
  }) async {
    // Cari room yang cocok (urutan user1/user2 bisa terbalik)
    final existing = await supabase
        .from('chat_rooms')
        .select('id')
        .or(
          'and(user1_id.eq.$senderId,user2_id.eq.$receiverId),'
          'and(user1_id.eq.$receiverId,user2_id.eq.$senderId)',
        )
        .maybeSingle();

    if (existing != null) {
      await supabase.from('chat_rooms').update({
        'last_message_content': content,
        'last_message_sender_id': senderId,
        'last_message_at': sentAt.toIso8601String(),
      }).eq('id', existing['id'] as String);
    }
  }

  @override
  Future<void> markMessagesAsRead(
    String senderId,
    String receiverId,
  ) async {
    await supabase
        .from('chat_messages')
        .update({'is_read': true})
        .eq('sender_id', senderId)
        .eq('receiver_id', receiverId)
        .eq('is_read', false);
  }

  @override
  Future<void> ensureChatRoomExists(
    String user1Id,
    String user2Id,
  ) async {
    final existing = await supabase
        .from('chat_rooms')
        .select('id')
        .or(
          'and(user1_id.eq.$user1Id,user2_id.eq.$user2Id),'
          'and(user1_id.eq.$user2Id,user2_id.eq.$user1Id)',
        )
        .maybeSingle();

    if (existing == null) {
      await supabase.from('chat_rooms').insert({
        'user1_id': user1Id,
        'user2_id': user2Id,
      });
    }
  }

  @override
  Stream<List<ChatMessageModel>> watchMessages(
    String user1Id,
    String user2Id,
  ) {
    return supabase
        .from('chat_messages')
        .stream(primaryKey: ['id'])
        .order('sent_at', ascending: true)
        .map((data) => data
            .where((j) =>
                (j['sender_id'] == user1Id && j['receiver_id'] == user2Id) ||
                (j['sender_id'] == user2Id && j['receiver_id'] == user1Id))
            .map((j) => ChatMessageModel.fromJson(j))
            .toList());
  }

  @override
  Stream<List<ChatRoomModel>> watchChatRooms(String userId) {
    return supabase
        .from('chat_rooms_with_users')
        .stream(primaryKey: ['id'])
        .order('last_message_at', ascending: false)
        .map((data) => data
            .where((j) =>
                j['user1_id'] == userId || j['user2_id'] == userId)
            .map((j) => ChatRoomModel.fromJson(j, userId))
            .toList());
  }
}