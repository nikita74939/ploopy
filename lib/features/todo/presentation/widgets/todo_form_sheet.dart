import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/todo_model.dart';

class TodoFormSheet extends StatefulWidget {
  final Todo? todo; // null = create, not null = edit

  const TodoFormSheet({super.key, this.todo});

  static Future<Todo?> showCreate(BuildContext context) {
    return showModalBottomSheet<Todo>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const TodoFormSheet(),
    );
  }

  static Future<Todo?> showEdit(BuildContext context, Todo todo) {
    return showModalBottomSheet<Todo>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => TodoFormSheet(todo: todo),
    );
  }

  @override
  State<TodoFormSheet> createState() => _TodoFormSheetState();
}

class _TodoFormSheetState extends State<TodoFormSheet> {
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  DateTime? _dueDate;
  String? _dueTime;
  TodoPriority _priority = TodoPriority.medium;
  TodoCategory _category = TodoCategory.personal;

  bool get _isEdit => widget.todo != null;

  @override
  void initState() {
    super.initState();
    final todo = widget.todo;
    _titleCtrl = TextEditingController(text: todo?.title ?? '');
    _descCtrl = TextEditingController(text: todo?.description ?? '');
    _dueDate = todo?.dueDate;
    _dueTime = todo?.dueTime;
    _priority = todo?.priority ?? TodoPriority.medium;
    _category = todo?.category ?? TodoCategory.personal;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) setState(() => _dueDate = date);
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _dueTime != null
          ? _parseTime(_dueTime!)
          : TimeOfDay.now(),
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (time != null) {
      setState(() {
        _dueTime =
            '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  TimeOfDay _parseTime(String str) {
    final parts = str.split(':');
    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 0,
      minute: int.tryParse(parts[1]) ?? 0,
    );
  }

  void _save() {
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Judul tugas wajib diisi',
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 12),
          ),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    final todo = _isEdit
        ? widget.todo!.copyWith(
            title: _titleCtrl.text.trim(),
            description: _descCtrl.text.trim(),
            dueDate: _dueDate,
            dueTime: _dueTime,
            priority: _priority,
            category: _category,
            clearDueDate: _dueDate == null,
            clearDueTime: _dueTime == null,
          )
        : Todo(
            id: '',
            title: _titleCtrl.text.trim(),
            description: _descCtrl.text.trim(),
            dueDate: _dueDate,
            dueTime: _dueTime,
            priority: _priority,
            category: _category,
            createdAt: DateTime.now(),
          );

    Navigator.pop(context, todo);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHandle(),
            _buildHeader(),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitleInput(),
                    const SizedBox(height: 14),
                    _buildDescInput(),
                    const SizedBox(height: 18),
                    _buildSectionLabel('📅 Jadwal'),
                    const SizedBox(height: 8),
                    _buildDateTimeRow(),
                    const SizedBox(height: 18),
                    _buildSectionLabel('🚩 Prioritas'),
                    const SizedBox(height: 8),
                    _buildPrioritySelector(),
                    const SizedBox(height: 18),
                    _buildSectionLabel('🏷️ Kategori'),
                    const SizedBox(height: 8),
                    _buildCategorySelector(),
                    const SizedBox(height: 24),
                    _buildSaveButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      width: 42,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
      child: Row(
        children: [
          Text(
            _isEdit ? 'Edit Tugas' : 'Tugas Baru',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleInput() {
    return TextField(
      controller: _titleCtrl,
      autofocus: !_isEdit,
      maxLength: 100,
      textCapitalization: TextCapitalization.sentences,
      style: GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
      decoration: InputDecoration(
        hintText: 'Apa yang mau dikerjakan?',
        hintStyle: GoogleFonts.poppins(
          fontSize: 15,
          color: Colors.grey.shade400,
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        counterText: '',
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildDescInput() {
    return TextField(
      controller: _descCtrl,
      maxLines: 3,
      maxLength: 200,
      textCapitalization: TextCapitalization.sentences,
      style: GoogleFonts.poppins(
        fontSize: 12,
        color: Colors.black87,
      ),
      decoration: InputDecoration(
        hintText: 'Deskripsi (opsional)',
        hintStyle: GoogleFonts.poppins(
          fontSize: 12,
          color: Colors.grey.shade400,
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        counterStyle: GoogleFonts.poppins(
          fontSize: 9,
          color: Colors.grey.shade400,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildDateTimeRow() {
    return Row(
      children: [
        Expanded(
          child: _buildPickerButton(
            icon: Icons.calendar_today_rounded,
            label: _dueDate != null ? _formatDate(_dueDate!) : 'Pilih Tanggal',
            hasValue: _dueDate != null,
            onTap: _pickDate,
            onClear: () => setState(() => _dueDate = null),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildPickerButton(
            icon: Icons.access_time_rounded,
            label: _dueTime ?? 'Pilih Jam',
            hasValue: _dueTime != null,
            onTap: _pickTime,
            onClear: () => setState(() => _dueTime = null),
          ),
        ),
      ],
    );
  }

  Widget _buildPickerButton({
    required IconData icon,
    required String label,
    required bool hasValue,
    required VoidCallback onTap,
    required VoidCallback onClear,
  }) {
    return Material(
      color: hasValue
          ? AppColors.primary.withOpacity(0.1)
          : Colors.grey.shade50,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(
                icon,
                size: 14,
                color: hasValue ? AppColors.primary : Colors.grey.shade600,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: hasValue ? AppColors.primary : Colors.grey.shade700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (hasValue)
                GestureDetector(
                  onTap: onClear,
                  child: Icon(
                    Icons.close_rounded,
                    size: 14,
                    color: AppColors.primary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrioritySelector() {
    final priorities = [
      (TodoPriority.low, 'Rendah', const Color(0xFF6BCB77)),
      (TodoPriority.medium, 'Sedang', const Color(0xFFFF8C42)),
      (TodoPriority.high, 'Tinggi', const Color(0xFFFF6B6B)),
    ];

    return Row(
      children: priorities.map((p) {
        final isSelected = _priority == p.$1;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: p != priorities.last ? 6 : 0),
            child: GestureDetector(
              onTap: () => setState(() => _priority = p.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? p.$3 : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? p.$3 : Colors.grey.shade200,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.flag_rounded,
                      size: 14,
                      color: isSelected ? Colors.white : p.$3,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      p.$2,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCategorySelector() {
    final categories = [
      (TodoCategory.study, '📚', 'Belajar', const Color(0xFF4D96FF)),
      (TodoCategory.work, '💼', 'Pekerjaan', const Color(0xFFB79CED)),
      (TodoCategory.health, '💪', 'Kesehatan', const Color(0xFF6BCB77)),
      (TodoCategory.personal, '💖', 'Pribadi', const Color(0xFFFFD166)),
      (TodoCategory.other, '📌', 'Lainnya', Colors.grey.shade500),
    ];

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: categories.map((c) {
        final isSelected = _category == c.$1;
        return GestureDetector(
          onTap: () => setState(() => _category = c.$1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? c.$4 : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? c.$4 : Colors.grey.shade200,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(c.$2, style: const TextStyle(fontSize: 13)),
                const SizedBox(width: 6),
                Text(
                  c.$3,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: _save,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            alignment: Alignment.center,
            child: Text(
              _isEdit ? 'Simpan Perubahan' : 'Tambah Tugas',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) return 'Hari ini';
    if (dateOnly == tomorrow) return 'Besok';

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${date.day} ${months[date.month - 1]}';
  }
}