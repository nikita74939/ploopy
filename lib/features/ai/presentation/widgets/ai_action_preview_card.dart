import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/ai_action.dart';
import 'action_event_card.dart';
import 'action_post_card.dart';
import 'action_todo_card.dart';

class AiActionPreviewCard extends StatefulWidget {
  final AiAction action;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final bool isProcessing;
  final bool isExecuted;
  final bool isCancelled;

  const AiActionPreviewCard({
    super.key,
    required this.action,
    required this.onConfirm,
    required this.onCancel,
    this.isProcessing = false,
    this.isExecuted = false,
    this.isCancelled = false,
  });

  @override
  State<AiActionPreviewCard> createState() => _AiActionPreviewCardState();
}

class _AiActionPreviewCardState extends State<AiActionPreviewCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildAiAvatar(),
          const SizedBox(width: 8),
          Flexible(child: _buildCard()),
        ],
      ),
    );
  }

  Widget _buildAiAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.greyBorder),
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.smart_toy_outlined,
        size: 17,
        color: AppColors.black,
      ),
    );
  }

  Widget _buildCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _getBorderColor(), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.action.message.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
              child: Text(
                widget.action.message,
                style: AppTextStyles.body.copyWith(height: 1.4),
              ),
            ),
          if (widget.isExecuted || widget.isCancelled) _buildStatusBanner(),
          if (!widget.isCancelled) ...[
            _buildPreviewHeader(),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: _buildActionContent(),
            ),
          ],
          if (!widget.isExecuted && !widget.isCancelled) _buildButtons(),
        ],
      ),
    );
  }

  Color _getBorderColor() {
    if (widget.isExecuted) return AppColors.primaryBorder;
    if (widget.isCancelled) return AppColors.greyBorder;
    return AppColors.greyBorder;
  }

  Widget _buildStatusBanner() {
    final isExec = widget.isExecuted;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: const BoxDecoration(
        color: AppColors.greyLight,
        border: Border(
          bottom: BorderSide(color: AppColors.greyBorder, width: 1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isExec ? Icons.check_circle_outline : Icons.cancel_outlined,
            size: 14,
            color: AppColors.black,
          ),
          const SizedBox(width: 6),
          Text(
            isExec ? 'Berhasil ditambahkan' : 'Dibatalkan',
            style: AppTextStyles.small.copyWith(
              color: AppColors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: const BoxDecoration(
        color: AppColors.greyLight,
        border: Border(
          top: BorderSide(color: AppColors.greyBorder, width: 1),
          bottom: BorderSide(color: AppColors.greyBorder, width: 1),
        ),
      ),
      child: Row(
        children: [
          Icon(_getActionIcon(), size: 14, color: AppColors.black),
          const SizedBox(width: 6),
          Text(
            'Preview ${widget.action.title}',
            style: AppTextStyles.small.copyWith(
              color: AppColors.black,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getActionIcon() {
    switch (widget.action.type) {
      case AiActionType.todo:
        return Icons.check_circle_outline;
      case AiActionType.event:
        return Icons.event_outlined;
      case AiActionType.post:
        return Icons.edit_note_outlined;
      case AiActionType.pomodoro:
        return Icons.timer_outlined;
      case AiActionType.none:
        return Icons.info_outline;
    }
  }

  Widget _buildActionContent() {
    switch (widget.action.type) {
      case AiActionType.todo:
        return ActionTodoCard(data: widget.action.data);
      case AiActionType.event:
        return ActionEventCard(data: widget.action.data);
      case AiActionType.post:
        return ActionPostCard(data: widget.action.data);
      case AiActionType.pomodoro:
        return _buildPomodoroCard();
      case AiActionType.none:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPomodoroCard() {
    final data = widget.action.data;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(
          Icons.timer_outlined,
          'Durasi',
          '${data['duration_minutes'] ?? 25} menit',
        ),
        _buildInfoRow(
          Icons.task_alt_outlined,
          'Task',
          data['task'] as String? ?? '-',
        ),
        _buildInfoRow(
          Icons.coffee_outlined,
          'Istirahat',
          '${data['breaks'] ?? 5} menit',
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.greyLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.greyBorder),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 14, color: AppColors.black),
          ),
          const SizedBox(width: 10),
          SizedBox(width: 70, child: Text(label, style: AppTextStyles.caption)),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      child: Row(
        children: [
          Expanded(child: _buildCancelButton()),
          const SizedBox(width: 8),
          Expanded(flex: 2, child: _buildConfirmButton()),
        ],
      ),
    );
  }

  Widget _buildCancelButton() {
    return Material(
      color: AppColors.greyLight,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: widget.isProcessing ? null : widget.onCancel,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.greyBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.close_rounded, size: 14, color: AppColors.grey),
              const SizedBox(width: 4),
              Text(
                'Batal',
                style: AppTextStyles.small.copyWith(
                  color: AppColors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmButton() {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: widget.isProcessing ? null : widget.onConfirm,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child:
              widget.isProcessing
                  ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Memproses...',
                        style: AppTextStyles.buttonPrimary.copyWith(
                          fontSize: 12,
                        ),
                      ),
                    ],
                  )
                  : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: AppColors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getConfirmText(),
                        style: AppTextStyles.buttonPrimary.copyWith(
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }

  String _getConfirmText() {
    switch (widget.action.type) {
      case AiActionType.todo:
        return 'Tambahkan';
      case AiActionType.event:
        return 'Buat Event';
      case AiActionType.post:
        return 'Post Sekarang';
      case AiActionType.pomodoro:
        return 'Mulai';
      case AiActionType.none:
        return 'OK';
    }
  }
}
