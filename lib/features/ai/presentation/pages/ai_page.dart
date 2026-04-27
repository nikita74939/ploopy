import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/services/action_handler_service.dart';
import '../../../../shared/services/ai_service.dart';
import '../../domain/ai_action.dart';
import '../widgets/ai_action_preview_card.dart';
import '../widgets/ai_chat_bubble.dart';
import '../widgets/ai_empty_state.dart';
import '../widgets/ai_input_bar.dart';
import '../widgets/ai_suggestion_chips.dart';
import '../widgets/ai_typing_indicator.dart';

class AiPage extends StatefulWidget {
  const AiPage({super.key});

  @override
  State<AiPage> createState() => _AiPageState();
}

class _AiPageState extends State<AiPage> {
  late final AiService _aiService;
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  final List<_ChatItem> _messages = [];
  bool _isLoading = false;
  String? _initError;

  @override
  void initState() {
    super.initState();
    _initAi();
  }

  void _initAi() {
    try {
      _aiService = AiService();
    } catch (e) {
      setState(() => _initError = e.toString());
    }
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage([String? prefilledText]) async {
    final text = (prefilledText ?? _inputCtrl.text).trim();
    if (text.isEmpty || _isLoading) return;

    setState(() {
      _messages.add(_ChatItem.user(text));
      _isLoading = true;
      _inputCtrl.clear();
    });

    _scrollToBottom();

    try {
      final action = await _aiService.sendMessage(text);

      if (!mounted) return;

      setState(() {
        if (action.type == AiActionType.none) {
          // Plain text response
          _messages.add(_ChatItem.ai(action.message));
        } else {
          // Action with preview card
          _messages.add(_ChatItem.action(action));
        }
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add(_ChatItem.error(e.toString()));
        _isLoading = false;
      });
    }

    _scrollToBottom();
  }

  Future<void> _confirmAction(int index) async {
    final item = _messages[index];
    if (item.action == null) return;

    setState(() => item.isProcessing = true);

    try {
      final result = await ActionHandlerService.execute(item.action!);

      if (!mounted) return;

      setState(() {
        item.isProcessing = false;
        if (result.success) {
          item.isExecuted = true;
        } else {
          _messages.add(_ChatItem.error(result.message));
        }
      });

      // Show success feedback
      if (result.success && mounted) {
        _showSuccessSnackbar(result.message);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        item.isProcessing = false;
        _messages.add(_ChatItem.error('Gagal: $e'));
      });
    }

    _scrollToBottom();
  }

  void _cancelAction(int index) {
    setState(() {
      _messages[index].isCancelled = true;
    });
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _resetChat() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              'Reset Chat?',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            content: Text(
              'Semua riwayat chat akan dihapus. Yakin?',
              style: GoogleFonts.poppins(fontSize: 12),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(
                  'Batal',
                  style: GoogleFonts.poppins(color: Colors.grey.shade600),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade400,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Reset',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
              ),
            ],
          ),
    );

    if (confirm == true) {
      _aiService.resetChat();
      setState(() => _messages.clear());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildBody()),
            if (_initError == null)
              AiInputBar(
                controller: _inputCtrl,
                onSend: _sendMessage,
                isLoading: _isLoading,
              ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFF8C42), Color(0xFFFF6B42)],
              ),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Text('🤖', style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Ploopy AI',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Online · Agentic Mode',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
        if (_messages.isNotEmpty && _initError == null)
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: Colors.grey.shade700),
            onPressed: _resetChat,
            tooltip: 'Reset Chat',
          ),
      ],
      shape: Border(bottom: BorderSide(color: Colors.grey.shade100, width: 1)),
    );
  }

  Widget _buildBody() {
    if (_initError != null) return _buildErrorState();

    if (_messages.isEmpty) {
      return Column(
        children: [
          const Expanded(child: AiEmptyState()),
          AiSuggestionChips(onSelected: _sendMessage),
          const SizedBox(height: 12),
        ],
      );
    }

    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: _messages.length + (_isLoading ? 1 : 0),
      itemBuilder: (_, i) {
        if (_isLoading && i == _messages.length) {
          return const AiTypingIndicator();
        }

        final item = _messages[i];

        // User message
        if (item.isUser) {
          return AiChatBubble(text: item.text, isUser: true);
        }

        // Error message
        if (item.isError) {
          return AiChatBubble(text: item.text, isUser: false, isError: true);
        }

        // AI action (preview card)
        if (item.action != null) {
          return AiActionPreviewCard(
            action: item.action!,
            onConfirm: () => _confirmAction(i),
            onCancel: () => _cancelAction(i),
            isProcessing: item.isProcessing,
            isExecuted: item.isExecuted,
            isCancelled: item.isCancelled,
          );
        }

        // AI plain text
        return AiChatBubble(text: item.text, isUser: false);
      },
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('😢', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              'AI belum siap',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _initError ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatItem {
  final bool isUser;
  final bool isError;
  final String text;
  final AiAction? action;
  bool isProcessing;
  bool isExecuted;
  bool isCancelled;

  _ChatItem({
    required this.isUser,
    required this.isError,
    required this.text,
    this.action,
    this.isProcessing = false,
    this.isExecuted = false,
    this.isCancelled = false,
  });

  factory _ChatItem.user(String text) =>
      _ChatItem(isUser: true, isError: false, text: text);

  factory _ChatItem.ai(String text) =>
      _ChatItem(isUser: false, isError: false, text: text);

  factory _ChatItem.error(String text) =>
      _ChatItem(isUser: false, isError: true, text: text);

  factory _ChatItem.action(AiAction action) => _ChatItem(
    isUser: false,
    isError: false,
    text: action.message,
    action: action,
  );
}
