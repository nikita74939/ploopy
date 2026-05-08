import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/neo_card.dart';
import '../../domain/entities/chat_room_entity.dart';
import '../bloc/chat_bloc.dart';

class ChatListPage extends StatefulWidget {
  final String currentUserId;

  const ChatListPage({super.key, required this.currentUserId});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  @override
  void initState() {
    super.initState();
    // Gunakan WatchChatRoomsEvent agar otomatis update realtime
    context.read<ChatBloc>().add(WatchChatRoomsEvent(widget.currentUserId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Chats'),
      ),
      body: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          if (state is ChatLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ChatRoomsLoaded) {
            if (state.rooms.isEmpty) {
              return _buildEmptyState();
            }
            return _buildChatList(state.rooms);
          }

          if (state is ChatError) {
            return Center(child: Text(state.message));
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to new chat / user search
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No chats yet',
            style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start a conversation with friends',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildChatList(List<ChatRoomEntity> rooms) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppStyle.paddingMedium),
      itemCount: rooms.length,
      itemBuilder: (context, index) {
        return _buildChatRoomTile(rooms[index]);
      },
    );
  }

  Widget _buildChatRoomTile(ChatRoomEntity room) {
    return NeoCard(
      onTap: () {
        // TODO: Navigate to ChatRoomPage
        // Navigator.push(context, MaterialPageRoute(
        //   builder: (_) => ChatRoomPage(
        //     userId: widget.currentUserId,
        //     otherUserId: room.otherUserId,
        //     otherUserName: room.otherUserName,
        //   ),
        // ));
      },
      child: Padding(
        padding: const EdgeInsets.all(AppStyle.paddingMedium),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundImage: room.otherUserAvatar != null
                  ? NetworkImage(room.otherUserAvatar!)
                  : null,
              backgroundColor: AppColors.primary.withOpacity(0.2),
              child: room.otherUserAvatar == null
                  ? const Icon(Icons.person, color: AppColors.primary)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.otherUserName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    room.lastMessage?.content ?? 'No messages yet',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (room.lastMessageAt != null)
                  Text(
                    _formatTime(room.lastMessageAt!),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                const SizedBox(height: 4),
                if (room.unreadCount > 0)
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        room.unreadCount > 9 ? '9+' : '${room.unreadCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    if (dt.day == now.day &&
        dt.month == now.month &&
        dt.year == now.year) {
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    return '${dt.day}/${dt.month}';
  }
}