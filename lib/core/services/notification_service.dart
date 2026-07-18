import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:go_router/go_router.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../router/app_router.dart';
import 'hive_service.dart';

/// Local notification IDs.
const int dailyStudyNotificationId = 1001;
const int unfinishedTestNotificationId = 1002;

const Duration unfinishedReminderDelay = Duration(hours: 2);

class NotificationService {
  NotificationService(this._hive);

  final HiveService _hive;
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneInfo.identifier));

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      settings: const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _initialized = true;
    await requestPermissions();
    await syncScheduledNotifications();
  }

  Future<void> requestPermissions() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();
    await android?.requestExactAlarmsPermission();

    final ios =
        _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    await ios?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> syncScheduledNotifications() async {
    if (!_initialized) return;

    if (_hive.isDailyReminderEnabled()) {
      await scheduleDailyStudyReminder(
        hour: _hive.getDailyReminderHour(),
        minute: _hive.getDailyReminderMinute(),
      );
    } else {
      await cancelDailyStudyReminder();
    }

    final unfinished = _hive.getUnfinishedTest();
    if (unfinished != null && _hive.isUnfinishedReminderEnabled()) {
      await scheduleUnfinishedTestReminder(
        module: unfinished['module'] as String,
        title: unfinished['title'] as String,
        currentIndex: unfinished['current_index'] as int,
        total: unfinished['total'] as int,
      );
    } else {
      await cancelUnfinishedTestReminder();
    }
  }

  Future<void> scheduleDailyStudyReminder({
    required int hour,
    required int minute,
  }) async {
    await _plugin.zonedSchedule(
      id: dailyStudyNotificationId,
      title: 'Time to study',
      body: 'Keep your driving theory on track with a quick practice session.',
      scheduledDate: _nextInstanceOfTime(hour, minute),
      notificationDetails: _defaultDetails(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'home',
    );
  }

  Future<void> cancelDailyStudyReminder() async {
    await _plugin.cancel(id: dailyStudyNotificationId);
  }

  Future<void> scheduleUnfinishedTestReminder({
    required String module,
    required String title,
    required int currentIndex,
    required int total,
  }) async {
    final answered = currentIndex + 1;
    await _plugin.zonedSchedule(
      id: unfinishedTestNotificationId,
      title: 'Unfinished test',
      body:
          'You left "$title" at question $answered of $total. Pick up where you left off.',
      scheduledDate: tz.TZDateTime.now(tz.local).add(unfinishedReminderDelay),
      notificationDetails: _defaultDetails(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: module,
    );
  }

  Future<void> cancelUnfinishedTestReminder() async {
    await _plugin.cancel(id: unfinishedTestNotificationId);
  }

  Future<void> recordUnfinishedTest({
    required String module,
    required String title,
    required int currentIndex,
    required int total,
  }) async {
    await _hive.saveUnfinishedTest(
      module: module,
      title: title,
      currentIndex: currentIndex,
      total: total,
    );

    if (_hive.isUnfinishedReminderEnabled()) {
      await scheduleUnfinishedTestReminder(
        module: module,
        title: title,
        currentIndex: currentIndex,
        total: total,
      );
    }
  }

  Future<void> clearUnfinishedTest({String? module}) async {
    await _hive.clearUnfinishedTest(module: module);
    await cancelUnfinishedTestReminder();
  }

  NotificationDetails _defaultDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'drive_prep_reminders',
        'Study reminders',
        channelDescription: 'Daily study and unfinished test reminders',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  void _onNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null) return;

    final context = rootNavigatorKey.currentContext;
    if (context == null) return;

    switch (payload) {
      case 'theory':
        context.go('/theory-quiz');
      case 'signs':
        context.go('/signs-quiz');
      case 'home':
        context.go('/home');
    }
  }
}
