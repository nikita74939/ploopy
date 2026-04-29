import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────
// Model
// ─────────────────────────────────────────────
enum NotifType { social, achievement, event, reminder, system }

class AppNotification {
  final String id;
  final NotifType type;
  final String title;
  final String body;
  final String time;
  final String? avatarLabel;
  final Color? avatarColor;
  final String? emoji;
  bool isRead;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.time,
    this.avatarLabel,
    this.avatarColor,
    this.emoji,
    this.isRead = false,
  });
}

// ─────────────────────────────────────────────
// Dummy Data
// ─────────────────────────────────────────────
final List<AppNotification> _dummyNotifications = [
  AppNotification(
    id: '1',
    type: NotifType.social,
    title: 'Andi Saputra menyukaimu',
    body: 'Andi menyukai postingan streak 30 harimu 🔥',
    time: '2m lalu',
    avatarLabel: 'A',
    avatarColor: const Color(0xFF4D96FF),
  ),
  AppNotification(
    id: '2',
    type: NotifType.achievement,
    title: 'Achievement Baru! 🏆',
    body: 'Kamu baru saja unlock "Konsisten 7 Hari" — terus semangat!',
    time: '15m lalu',
    emoji: '🏆',
  ),
  AppNotification(
    id: '3',
    type: NotifType.social,
    title: 'Bella Pratiwi berkomentar',
    body: '"Keren banget! Aku juga mau coba streak kayak gini 💪"',
    time: '1j lalu',
    avatarLabel: 'B',
    avatarColor: const Color(0xFFFF6B6B),
    isRead: true,
  ),
  AppNotification(
    id: '4',
    type: NotifType.reminder,
    title: 'Waktunya Belajar! ⏰',
    body: 'Kamu belum mencatat aktivitas hari ini. Yuk mulai sesi belajarmu!',
    time: '2j lalu',
    emoji: '⏰',
    isRead: true,
  ),
  AppNotification(
    id: '5',
    type: NotifType.event,
    title: 'Event dimulai besok',
    body: 'Study Together — Persiapan UAS Kalkulus dimulai besok jam 09.00',
    time: '3j lalu',
    emoji: '📅',
    isRead: true,
  ),
  AppNotification(
    id: '6',
    type: NotifType.social,
    title: 'Doni Herlambang mengikutimu',
    body: 'Doni mulai mengikuti aktivitasmu',
    time: '5j lalu',
    avatarLabel: 'D',
    avatarColor: const Color(0xFFB79CED),
    isRead: true,
  ),
  AppNotification(
    id: '7',
    type: NotifType.achievement,
    title: 'Hampir sampai! 🎯',
    body: 'Tinggal 2 jam lagi untuk unlock "Brain Master 50 Jam"',
    time: '1h lalu',
    emoji: '🎯',
    isRead: true,
  ),
  AppNotification(
    id: '8',
    type: NotifType.system,
    title: 'Fitur Baru Tersedia',
    body: 'Location-Based Study Buddy kini aktif di sekitarmu. Coba sekarang!',
    time: '1h lalu',
    emoji: '📍',
    isRead: true,
  ),
];

// ─────────────────────────────────────────────
// Page
// ─────────────────────────────────────────────
class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage>
    with SingleTickerProviderStateMixin {
  late final List<AppNotification> _notifications;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _notifications = List.from(_dummyNotifications);
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  List<AppNotification> get _unread =>
      _notifications.where((n) => !n.isRead).toList();

  List<AppNotification> get _all => _notifications;

  void _markAllRead() {
    HapticFeedback.lightImpact();
    setState(() {
      for (final n in _notifications) {
        n.isRead = true;
      }
    });
  }

  void _markRead(AppNotification notif) {
    if (!notif.isRead) {
      setState(() => notif.isRead = true);
    }
  }

  void _deleteNotif(AppNotification notif) {
    HapticFeedback.mediumImpact();
    setState(() => _notifications.remove(notif));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildList(_all),
                  _buildList(_unread),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            color: Colors.black87,
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              'Notifikasi',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ),
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllRead,
              child: Text(
                'Tandai semua',
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

  // ── Tab Bar ─────────────────────────────────
  Widget _buildTabBar() {
  return Container(
    margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
    decoration: BoxDecoration(
      color: Colors.grey.shade200,
      borderRadius: BorderRadius.circular(12),
    ),
    child: TabBar(
      controller: _tabController,
      indicator: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      indicatorSize: TabBarIndicatorSize.tab,
      dividerColor: Colors.transparent,
      labelStyle: GoogleFonts.poppins(
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      unselectedLabelStyle: GoogleFonts.poppins(
        fontWeight: FontWeight.w500,
        fontSize: 13,
      ),
      labelColor: Colors.black87,
      unselectedLabelColor: Colors.grey.shade500,
      tabs: [
        const Tab(text: 'Semua'),
        Tab(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Belum Dibaca'),
              if (_unreadCount > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.red.shade500,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$_unreadCount',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}

  // ── List ────────────────────────────────────
  Widget _buildList(List<AppNotification> items) {
    if (items.isEmpty) {
      return _buildEmpty();
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: items.length,
      itemBuilder: (ctx, i) => _buildItem(items[i]),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🔔', style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(
            'Tidak ada notifikasi',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Semua sudah terbaca nih!',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  // ── Item ─────────────────────────────────────
  Widget _buildItem(AppNotification notif) {
    return Dismissible(
      key: Key(notif.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded,
            color: Colors.white, size: 24),
      ),
      onDismissed: (_) => _deleteNotif(notif),
      child: GestureDetector(
        onTap: () => _markRead(notif),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: notif.isRead ? Colors.white : const Color(0xFFF0F4FF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: notif.isRead
                  ? Colors.grey.shade100
                  : const Color(0xFFCBD9FF),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAvatar(notif),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notif.title,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: notif.isRead
                                  ? FontWeight.w500
                                  : FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        if (!notif.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(left: 6, top: 4),
                            decoration: const BoxDecoration(
                              color: Color(0xFF4D96FF),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      notif.body,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _buildTypeBadge(notif.type),
                        const Spacer(),
                        Text(
                          notif.time,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(AppNotification notif) {
    if (notif.avatarLabel != null) {
      return Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: notif.avatarColor ?? Colors.grey,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            notif.avatarLabel!,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      );
    }
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: _typeColor(notif.type).withOpacity(0.12),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(notif.emoji ?? '🔔',
            style: const TextStyle(fontSize: 20)),
      ),
    );
  }

  Widget _buildTypeBadge(NotifType type) {
    final (label, color) = switch (type) {
      NotifType.social => ('Sosial', const Color(0xFF4D96FF)),
      NotifType.achievement => ('Achievement', const Color(0xFFFFB347)),
      NotifType.event => ('Event', const Color(0xFF6BCB77)),
      NotifType.reminder => ('Reminder', const Color(0xFFB79CED)),
      NotifType.system => ('Sistem', Colors.grey),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Color _typeColor(NotifType type) => switch (type) {
        NotifType.social => const Color(0xFF4D96FF),
        NotifType.achievement => const Color(0xFFFFB347),
        NotifType.event => const Color(0xFF6BCB77),
        NotifType.reminder => const Color(0xFFB79CED),
        NotifType.system => Colors.grey,
      };
}