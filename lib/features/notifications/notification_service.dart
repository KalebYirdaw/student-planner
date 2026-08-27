import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  // ============================================================
  // SINGLETON
  // ============================================================

  NotificationService._internal();

  static final NotificationService instance = NotificationService._internal();

  factory NotificationService() {
    return instance;
  }

  // ============================================================
  // NOTIFICATION PLUGIN
  // ============================================================

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // ============================================================
  // CHANNEL
  // ============================================================

  static const String _channelId = 'student_planner_reminders';

  static const String _channelName = 'Student Planner Reminders';

  static const String _channelDescription =
      'Notifications for tasks, assignments and study reminders.';

  // ============================================================
  // INITIALIZATION
  // ============================================================

  Future<void> initialize() async {
    // Initialize timezone database.
    tz.initializeTimeZones();

    // Android initialization settings.
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // General initialization settings.
    const initializationSettings = InitializationSettings(
      android: androidSettings,
    );

    // Initialize notification plugin.
    await _notificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create Android notification channel.
    await _createNotificationChannel();
  }

  // ============================================================
  // CREATE NOTIFICATION CHANNEL
  // ============================================================

  Future<void> _createNotificationChannel() async {
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
    );

    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.createNotificationChannel(channel);
  }

  // ============================================================
  // REQUEST PERMISSION
  // ============================================================

  Future<bool> requestPermission() async {
    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin == null) {
      debugPrint('Android notification plugin is unavailable.');

      return false;
    }

    // ----------------------------------------------------------
    // REQUEST NOTIFICATION PERMISSION
    // ----------------------------------------------------------

    final notificationGranted = await androidPlugin
        .requestNotificationsPermission();

    debugPrint('Notification permission: $notificationGranted');

    // ----------------------------------------------------------
    // REQUEST EXACT ALARM PERMISSION
    // ----------------------------------------------------------

    final exactAlarmGranted = await androidPlugin
        .requestExactAlarmsPermission();

    debugPrint('Exact alarm permission: $exactAlarmGranted');

    // ----------------------------------------------------------
    // RETURN FINAL PERMISSION STATUS
    // ----------------------------------------------------------

    return notificationGranted == true && exactAlarmGranted == true;
  }

  // ============================================================
  // SHOW TEST NOTIFICATION
  // ============================================================

  Future<void> showTestNotification() async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      id: 999,
      title: 'Student Planner',
      body: 'Notifications are working!',
      notificationDetails: notificationDetails,
    );
  }

  // ============================================================
  // SCHEDULE NOTIFICATION
  // ============================================================

  Future<bool> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    // Convert DateTime into timezone-aware TZDateTime.
    final tz.TZDateTime scheduledTZDate = tz.TZDateTime.from(
      scheduledDate,
      tz.local,
    );

    // Current timezone-aware time.
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);

    // Don't schedule notifications in the past.
    if (scheduledTZDate.isBefore(now)) {
      debugPrint(
        'Notification was not scheduled because '
        'the scheduled time is in the past.',
      );

      return false;
    }

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledTZDate,
      notificationDetails: notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    debugPrint(
      'Notification scheduled: '
      '$title at $scheduledTZDate',
    );

    return true;
  }

  // ============================================================
  // CANCEL NOTIFICATION
  // ============================================================

  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id: id);

    debugPrint('Notification cancelled: $id');
  }

  // ============================================================
  // CANCEL ALL NOTIFICATIONS
  // ============================================================

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();

    debugPrint('All notifications cancelled.');
  }

  // ============================================================
  // NOTIFICATION TAP
  // ============================================================

  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');

    // Navigation will be added later.
  }
}
