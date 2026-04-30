// chat/presentation/pages/chat_room_page.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/chat_room_dummy_data.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_date_separator.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/chat_room_app_bar.dart';

class ChatRoomPage extends StatefulWidget {
  final Map<String, dynamic> chat;

  const ChatRoomPage({super.key, required this.chat});

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final TextEditingController _messageCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  late List<Map<String, dynamic>> _messages;

  @override
  void initState() {
    super.initState();
    _messages = List<Map<String, dynamic>>.from(ChatRoomDummyData.messages);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom(animated: false);
    });
  }

  void _scrollToBottom({bool animated = true}) {
    if (!_scrollCtrl.hasClients) return;
    if (animated) {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _scrollCtrl.jumpTo(_scrollCtrl.position.maxScrollExtent);
    }
  }

  void _sendMessage() {
    final text = _messageCtrl.text.trim();
    if (text.isEmpty) return;

    final now = DateTime.now();
    final time = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    setState(() {
      _messages.add({
        'type': 'message',
        'isMe': true,
        'text': text,
        'time': time,
        'read': false,
      });
    });

    _messageCtrl.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _messageCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: ChatRoomAppBar(chat: widget.chat),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          ChatInputBar(
            controller: _messageCtrl,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
      itemCount: _messages.length,
      itemBuilder: (_, i) {
        final msg = _messages[i];

        if (msg['type'] == 'date') {
          return ChatDateSeparator(date: msg['date'] as String);
        }

        final showTime = _shouldShowTime(i);

        return ChatBubble(message: msg, showTime: showTime);
      },
    );
  }

  bool _shouldShowTime(int index) {
    if (index == _messages.length - 1) return true;

    final current = _messages[index];
    final next = _messages[index + 1];

    if (next['type'] == 'date') return true;
    if (current['isMe'] != next['isMe']) return true;
    if (current['time'] != next['time']) return true;

    return false;
  }
}