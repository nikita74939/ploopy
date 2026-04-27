import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  /// Initialize notification service (panggil di main.dart)
  static Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);
    await _requestPermissions();

    _initialized = true;
  }

  static Future<void> _requestPermissions() async {
    // Android 13+ permission
    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // iOS permission
    await _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  /// Show simple notification
  static Future<void> show({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'ploopy_pomodoro',
      'Pomodoro Timer',
      channelDescription: 'Notifikasi untuk timer pomodoro',
      importance: Importance.max,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, details, payload: payload);
  }

  /// Show focus completed notification
  static Future<void> showFocusComplete() async {
    await show(
      id: 1,
      title: '🎉 Sesi Fokus Selesai!',
      body: 'Kerja bagus! Saatnya istirahat sebentar 😌',
    );
  }

  /// Show break completed notification
  static Future<void> showBreakComplete() async {
    await show(
      id: 2,
      title: '⏰ Istirahat Selesai',
      body: 'Ayo lanjut fokus! Kamu pasti bisa 💪',
    );
  }

  /// Show long break completed notification
  static Future<void> showLongBreakComplete() async {
    await show(
      id: 3,
      title: '☕ Istirahat Panjang Selesai',
      body: 'Siap untuk sesi fokus berikutnya? 🚀',
    );
  }

  /// Cancel all notifications
  static Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}