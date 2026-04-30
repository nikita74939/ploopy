import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ploopy/core/theme/app_colors.dart';
import 'package:ploopy/core/theme/app_text_styles.dart';

enum NotifType { social, achievement, event, reminder, system }

class AppNotification {
  final String id;
  final NotifType type;
  final String title;
  final String body;
  final String time;
  final String? avatarLabel;
  bool isRead;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.time,
    this.avatarLabel,
    this.isRead = false,
  });
}

final List<AppNotification> _dummyNotifications = [
  AppNotification(
    id: '1',
    type: NotifType.social,
    title: 'Andi Saputra menyukaimu',
    body: 'Andi menyukai postingan streak 30 harimu',
    time: '2m lalu',
    avatarLabel: 'A',
  ),
  AppNotification(
    id: '2',
    type: NotifType.achievement,
    title: 'Achievement Baru',
    body: 'Kamu baru saja unlock "Konsisten 7 Hari". Terus semangat!',
    time: '15m lalu',
  ),
  AppNotification(
    id: '3',
    type: NotifType.social,
    title: 'Bella Pratiwi berkomentar',
    body: '"Keren banget! Aku juga mau coba streak kayak gini"',
    time: '1j lalu',
    avatarLabel: 'B',
    isRead: true,
  ),
  AppNotification(
    id: '4',
    type: NotifType.reminder,
    title: 'Waktunya Belajar',
    body: 'Kamu belum mencatat aktivitas hari ini. Yuk mulai sesi belajarmu!',
    time: '2j lalu',
    isRead: true,
  ),
  AppNotification(
    id: '5',
    type: NotifType.event,
    title: 'Event dimulai besok',
    body: 'Study Together - Persiapan UAS Kalkulus dimulai besok jam 09.00',
    time: '3j lalu',
    isRead: true,
  ),
  AppNotification(
    id: '6',
    type: NotifType.social,
    title: 'Doni Herlambang mengikutimu',
    body: 'Doni mulai mengikuti aktivitasmu',
    time: '5j lalu',
    avatarLabel: 'D',
    isRead: true,
  ),
  AppNotification(
    id: '7',
    type: NotifType.achievement,
    title: 'Hampir sampai',
    body: 'Tinggal 2 jam lagi untuk unlock "Brain Master 50 Jam"',
    time: '1h lalu',
    isRead: true,
  ),
  AppNotification(
    id: '8',
    type: NotifType.system,
    title: 'Fitur Baru Tersedia',
    body: 'Location-Based Study Buddy kini aktif di sekitarmu. Coba sekarang!',
    time: '1h lalu',
    isRead: true,
  ),
];

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage>
    with SingleTickerProviderStateMixin {
  late final List<AppNotification> _notifications;
  late final TabController _tabController;

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

  void _markAllRead() {
    HapticFeedback.lightImpact();
    setState(() {
      for (final notification in _notifications) {
        notification.isRead = true;
      }
    });
  }

  void _markRead(AppNotification notification) {
    if (!notification.isRead) {
      setState(() => notification.isRead = true);
    }
  }

  void _deleteNotification(AppNotification notification) {
    HapticFeedback.mediumImpact();
    setState(() => _notifications.remove(notification));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyLighter,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildList(_notifications), _buildList(_unread)],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 10, 12, 10),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            color: AppColors.black,
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              'Notifikasi',
              style: AppTextStyles.heading.copyWith(fontSize: 18),
            ),
          ),
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllRead,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                minimumSize: const Size(0, 36),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Tandai semua',
                style: AppTextStyles.link.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 44,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.greyLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.greyBorder),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.primaryBorder),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: AppColors.black,
        labelStyle: AppTextStyles.tabActive,
        unselectedLabelColor: AppColors.grey,
        unselectedLabelStyle: AppTextStyles.tabInactive,
        tabs: [
          const Tab(text: 'Semua'),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Belum Dibaca'),
                if (_unreadCount > 0) ...[
                  const SizedBox(width: 6),
                  _buildUnreadCount(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnreadCount() {
    return Container(
      constraints: const BoxConstraints(minWidth: 18),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$_unreadCount',
        textAlign: TextAlign.center,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.white,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildList(List<AppNotification> items) {
    if (items.isEmpty) {
      return _buildEmpty();
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: items.length,
      itemBuilder: (context, index) => _buildItem(items[index]),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.greyLight,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.greyBorder),
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: AppColors.grey,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Tidak ada notifikasi',
            style: AppTextStyles.heading.copyWith(fontSize: 15),
          ),
          const SizedBox(height: 4),
          Text('Semua sudah terbaca nih!', style: AppTextStyles.caption),
        ],
      ),
    );
  }

  Widget _buildItem(AppNotification notification) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 18),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.black,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: AppColors.white,
          size: 22,
        ),
      ),
      onDismissed: (_) => _deleteNotification(notification),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _markRead(notification),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color:
                notification.isRead ? AppColors.white : AppColors.primaryLight,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color:
                  notification.isRead
                      ? AppColors.greyBorder
                      : AppColors.primary,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAvatar(notification),
              const SizedBox(width: 12),
              Expanded(child: _buildContent(notification)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(AppNotification notification) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                notification.title,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.black,
                  fontWeight:
                      notification.isRead ? FontWeight.w500 : FontWeight.w600,
                ),
              ),
            ),
            if (!notification.isRead)
              Container(
                width: 7,
                height: 7,
                margin: const EdgeInsets.only(left: 8, top: 6),
                decoration: const BoxDecoration(
                  color: AppColors.black,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          notification.body,
          style: AppTextStyles.subtitle.copyWith(fontSize: 12, height: 1.45),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildTypeBadge(notification.type),
            const Spacer(),
            Text(
              notification.time,
              style: AppTextStyles.caption.copyWith(fontSize: 11),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAvatar(AppNotification notification) {
    final isRead = notification.isRead;
    final foreground = isRead ? AppColors.black : AppColors.white;

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isRead ? AppColors.white : AppColors.black,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.greyBorder),
      ),
      child: Center(
        child:
            notification.avatarLabel == null
                ? Icon(
                  _typeIcon(notification.type),
                  size: 19,
                  color: foreground,
                )
                : Text(
                  notification.avatarLabel!,
                  style: AppTextStyles.body.copyWith(
                    color: foreground,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
      ),
    );
  }

  Widget _buildTypeBadge(NotifType type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.greyLight,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: AppColors.greyBorder),
      ),
      child: Text(
        _typeLabel(type),
        style: AppTextStyles.caption.copyWith(
          color: AppColors.greyText,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _typeLabel(NotifType type) => switch (type) {
    NotifType.social => 'Sosial',
    NotifType.achievement => 'Achievement',
    NotifType.event => 'Event',
    NotifType.reminder => 'Reminder',
    NotifType.system => 'Sistem',
  };

  IconData _typeIcon(NotifType type) => switch (type) {
    NotifType.social => Icons.person_outline_rounded,
    NotifType.achievement => Icons.workspace_premium_outlined,
    NotifType.event => Icons.event_outlined,
    NotifType.reminder => Icons.schedule_outlined,
    NotifType.system => Icons.notifications_none_rounded,
  };
}
