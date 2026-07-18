import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/hive_service.dart';
import '../services/notification_service.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(ref.watch(hiveServiceProvider));
});

class NotificationSettings {
  const NotificationSettings({
    required this.dailyReminderEnabled,
    required this.dailyReminderHour,
    required this.dailyReminderMinute,
    required this.unfinishedReminderEnabled,
  });

  final bool dailyReminderEnabled;
  final int dailyReminderHour;
  final int dailyReminderMinute;
  final bool unfinishedReminderEnabled;

  String get dailyReminderLabel {
    final h = dailyReminderHour.toString().padLeft(2, '0');
    final m = dailyReminderMinute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

final notificationSettingsProvider =
    StateNotifierProvider<NotificationSettingsNotifier, NotificationSettings>((ref) {
  return NotificationSettingsNotifier(ref);
});

class NotificationSettingsNotifier extends StateNotifier<NotificationSettings> {
  NotificationSettingsNotifier(this._ref)
      : super(_loadSettings(_ref.read(hiveServiceProvider)));

  final Ref _ref;

  static NotificationSettings _loadSettings(HiveService hive) {
    return NotificationSettings(
      dailyReminderEnabled: hive.isDailyReminderEnabled(),
      dailyReminderHour: hive.getDailyReminderHour(),
      dailyReminderMinute: hive.getDailyReminderMinute(),
      unfinishedReminderEnabled: hive.isUnfinishedReminderEnabled(),
    );
  }

  NotificationService get _notifications => _ref.read(notificationServiceProvider);
  HiveService get _hive => _ref.read(hiveServiceProvider);

  Future<void> setDailyReminderEnabled(bool enabled) async {
    await _hive.setDailyReminderEnabled(enabled);
    state = NotificationSettings(
      dailyReminderEnabled: enabled,
      dailyReminderHour: state.dailyReminderHour,
      dailyReminderMinute: state.dailyReminderMinute,
      unfinishedReminderEnabled: state.unfinishedReminderEnabled,
    );
    if (enabled) {
      await _notifications.scheduleDailyStudyReminder(
        hour: state.dailyReminderHour,
        minute: state.dailyReminderMinute,
      );
    } else {
      await _notifications.cancelDailyStudyReminder();
    }
  }

  Future<void> setDailyReminderTime({required int hour, required int minute}) async {
    await _hive.setDailyReminderTime(hour: hour, minute: minute);
    state = NotificationSettings(
      dailyReminderEnabled: state.dailyReminderEnabled,
      dailyReminderHour: hour,
      dailyReminderMinute: minute,
      unfinishedReminderEnabled: state.unfinishedReminderEnabled,
    );
    if (state.dailyReminderEnabled) {
      await _notifications.scheduleDailyStudyReminder(hour: hour, minute: minute);
    }
  }

  Future<void> setUnfinishedReminderEnabled(bool enabled) async {
    await _hive.setUnfinishedReminderEnabled(enabled);
    state = NotificationSettings(
      dailyReminderEnabled: state.dailyReminderEnabled,
      dailyReminderHour: state.dailyReminderHour,
      dailyReminderMinute: state.dailyReminderMinute,
      unfinishedReminderEnabled: enabled,
    );
    if (enabled) {
      final unfinished = _hive.getUnfinishedTest();
      if (unfinished != null) {
        await _notifications.scheduleUnfinishedTestReminder(
          module: unfinished['module'] as String,
          title: unfinished['title'] as String,
          currentIndex: unfinished['current_index'] as int,
          total: unfinished['total'] as int,
        );
      }
    } else {
      await _notifications.cancelUnfinishedTestReminder();
    }
  }
}

/// Persists unfinished quiz progress and schedules a reminder when enabled.
Future<void> saveUnfinishedQuizReminder(
  WidgetRef ref, {
  required String module,
  required String title,
  required int currentIndex,
  required int total,
}) async {
  if (total <= 0) return;
  await ref.read(notificationServiceProvider).recordUnfinishedTest(
        module: module,
        title: title,
        currentIndex: currentIndex,
        total: total,
      );
}

Future<void> clearUnfinishedQuizReminder(WidgetRef ref, {String? module}) async {
  await ref.read(notificationServiceProvider).clearUnfinishedTest(module: module);
}
