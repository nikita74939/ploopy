import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
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
  final String? initialPrompt;
  const AiPage({super.key, this.initialPrompt});

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
    if (widget.initialPrompt != null && widget.initialPrompt!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _sendMessage(widget.initialPrompt!);
      });
    }
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
          _messages.add(_ChatItem.ai(action.message));
        } else {
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
            const Icon(Icons.check_circle_outline, color: AppColors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.small.copyWith(color: AppColors.white),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
              borderRadius: BorderRadius.circular(8),
            ),
            title: Text('Reset Chat?', style: AppTextStyles.heading),
            content: Text(
              'Semua riwayat chat akan dihapus. Yakin?',
              style: AppTextStyles.body,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(
                  'Batal',
                  style: AppTextStyles.body.copyWith(color: AppColors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('Reset', style: AppTextStyles.buttonPrimary),
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
      backgroundColor: AppColors.greyLighter,
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
      backgroundColor: AppColors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: AppColors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.greyBorder),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.smart_toy_outlined,
              size: 18,
              color: AppColors.black,
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Ploopy AI', style: AppTextStyles.heading),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.black,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text('Online - Agentic Mode', style: AppTextStyles.caption),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
        if (_messages.isNotEmpty && _initError == null)
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.grey),
            onPressed: _resetChat,
            tooltip: 'Reset Chat',
          ),
      ],
      shape: const Border(
        bottom: BorderSide(color: AppColors.greyBorder, width: 1),
      ),
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

        if (item.isUser) {
          return AiChatBubble(text: item.text, isUser: true);
        }

        if (item.isError) {
          return AiChatBubble(text: item.text, isUser: false, isError: true);
        }

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
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.greyLight,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.greyBorder),
              ),
              child: const Icon(
                Icons.cloud_off_outlined,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 16),
            Text('AI belum siap', style: AppTextStyles.heading),
            const SizedBox(height: 6),
            Text(
              _initError ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: AppTextStyles.small,
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
  bool isProcessing = false;
  bool isExecuted = false;
  bool isCancelled = false;

  _ChatItem({
    required this.isUser,
    required this.isError,
    required this.text,
    this.action,
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
