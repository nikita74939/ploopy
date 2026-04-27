import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
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
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFF8C42), Color(0xFFFF6B42)],
        ),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: const Text('🤖', style: TextStyle(fontSize: 16)),
    );
  }

  Widget _buildCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(18),
          bottomLeft: Radius.circular(4),
          bottomRight: Radius.circular(18),
        ),
        border: Border.all(
          color: _getBorderColor(),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI message
          if (widget.action.message.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
              child: Text(
                widget.action.message,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
            ),

          // Status banner (if executed/cancelled)
          if (widget.isExecuted || widget.isCancelled) _buildStatusBanner(),

          // Preview card
          if (!widget.isCancelled) ...[
            _buildPreviewHeader(),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: _buildActionContent(),
            ),
          ],

          // Action buttons (hanya tampil kalau belum di-execute/cancel)
          if (!widget.isExecuted && !widget.isCancelled) _buildButtons(),
        ],
      ),
    );
  }

  Color _getBorderColor() {
    if (widget.isExecuted) return Colors.green.shade300;
    if (widget.isCancelled) return Colors.grey.shade300;
    return AppColors.primary.withOpacity(0.3);
  }

  Widget _buildStatusBanner() {
    final isExec = widget.isExecuted;
    final color = isExec ? Colors.green : Colors.grey;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.shade50,
        border: Border(
          bottom: BorderSide(color: color.shade100, width: 1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isExec ? Icons.check_circle_rounded : Icons.cancel_rounded,
            size: 14,
            color: color.shade600,
          ),
          const SizedBox(width: 6),
          Text(
            isExec ? 'Berhasil ditambahkan' : 'Dibatalkan',
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color.shade700,
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
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.06),
        border: Border(
          top: BorderSide(
            color: AppColors.primary.withOpacity(0.1),
            width: 1,
          ),
          bottom: BorderSide(
            color: AppColors.primary.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Text(widget.action.emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(
            'PREVIEW: ${widget.action.title.toUpperCase()}',
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
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
          Icons.timer_rounded,
          const Color(0xFFFF8C42),
          'Durasi',
          '${data['duration_minutes'] ?? 25} menit',
        ),
        _buildInfoRow(
          Icons.task_alt_rounded,
          const Color(0xFF6BCB77),
          'Task',
          data['task'] as String? ?? '-',
        ),
        _buildInfoRow(
          Icons.coffee_rounded,
          const Color(0xFFB79CED),
          'Istirahat',
          '${data['breaks'] ?? 5} menit',
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, Color color, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
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
          Expanded(
            child: _buildCancelButton(),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: _buildConfirmButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelButton() {
    return Material(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: widget.isProcessing ? null : widget.onCancel,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.close_rounded,
                size: 14,
                color: Colors.grey.shade700,
              ),
              const SizedBox(width: 4),
              Text(
                'Batal',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
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
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: widget.isProcessing ? null : widget.onConfirm,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: widget.isProcessing
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Memproses...',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
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
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getConfirmText(),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
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