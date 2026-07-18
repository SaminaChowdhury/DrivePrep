import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});

class HiveService {
  static bool _hiveCoreInitialized = false;

  // Local Hive boxes
  static const String settingsBoxName = 'settings_box';
  static const String questionsBoxName = 'questions_box';
  static const String roadSignsBoxName = 'road_signs_box';
  static const String highwayCodeBoxName = 'highway_code_box';
  static const String bookmarksBoxName = 'bookmarks_box';
  static const String progressBoxName = 'progress_box';

  static const String _bookmarkQuestionIdsKey = 'question_ids';

  /// Initializes Hive and opens all offline boxes.
  Future<void> init() async {
    if (!_hiveCoreInitialized) {
      await Hive.initFlutter();
      _hiveCoreInitialized = true;
    }

    await _openBoxIfNeeded(settingsBoxName);
    await _openBoxIfNeeded(questionsBoxName);
    await _openBoxIfNeeded(roadSignsBoxName);
    await _openBoxIfNeeded(highwayCodeBoxName);
    await _openBoxIfNeeded(bookmarksBoxName);
    await _openBoxIfNeeded(progressBoxName);

    await _migrateLegacyBookmarks();
    await _migrateLegacySeedFlags();
  }

  Box<dynamic> get settingsBox => Hive.box<dynamic>(settingsBoxName);
  Box<dynamic> get bookmarksBox => Hive.box<dynamic>(bookmarksBoxName);
  Box<dynamic> get progressBox => Hive.box<dynamic>(progressBoxName);

  // ── Settings ──────────────────────────────────────────────────────────────

  bool isOnboardingComplete() {
    return settingsBox.get('onboarding_complete', defaultValue: false) as bool;
  }

  Future<void> setOnboardingComplete(bool complete) async {
    await settingsBox.put('onboarding_complete', complete);
  }

  bool isDarkMode() {
    return settingsBox.get('dark_mode', defaultValue: false) as bool;
  }

  Future<void> setDarkMode(bool isDark) async {
    await settingsBox.put('dark_mode', isDark);
  }

  DateTime? getLastSyncAt() {
    final raw = settingsBox.get('last_sync_at') as String?;
    return raw == null ? null : DateTime.tryParse(raw);
  }

  Future<void> setLastSyncAt(DateTime time) async {
    await settingsBox.put('last_sync_at', time.toIso8601String());
  }

  bool isQuestionsSeeded() {
    return settingsBox.get('questions_seeded', defaultValue: false) as bool ||
        settingsBox.get('db_seeded', defaultValue: false) as bool;
  }

  Future<void> setQuestionsSeeded(bool seeded) async {
    await settingsBox.put('questions_seeded', seeded);
    await settingsBox.put('db_seeded', seeded);
  }

  @Deprecated('Use isQuestionsSeeded')
  bool isDatabaseSeeded() => isQuestionsSeeded();

  @Deprecated('Use setQuestionsSeeded')
  Future<void> setDatabaseSeeded(bool seeded) => setQuestionsSeeded(seeded);

  bool isRoadSignsSeeded() {
    return settingsBox.get('road_signs_seeded', defaultValue: false) as bool;
  }

  Future<void> setRoadSignsSeeded(bool seeded) async {
    await settingsBox.put('road_signs_seeded', seeded);
  }

  bool isHighwayCodeSeeded() {
    return settingsBox.get('highway_code_seeded', defaultValue: false) as bool;
  }

  Future<void> setHighwayCodeSeeded(bool seeded) async {
    await settingsBox.put('highway_code_seeded', seeded);
  }

  // ── Notification settings ─────────────────────────────────────────────────

  bool isDailyReminderEnabled() {
    return settingsBox.get('daily_reminder_enabled', defaultValue: true) as bool;
  }

  Future<void> setDailyReminderEnabled(bool enabled) async {
    await settingsBox.put('daily_reminder_enabled', enabled);
  }

  int getDailyReminderHour() {
    return settingsBox.get('daily_reminder_hour', defaultValue: 9) as int;
  }

  int getDailyReminderMinute() {
    return settingsBox.get('daily_reminder_minute', defaultValue: 0) as int;
  }

  Future<void> setDailyReminderTime({required int hour, required int minute}) async {
    await settingsBox.put('daily_reminder_hour', hour);
    await settingsBox.put('daily_reminder_minute', minute);
  }

  bool isUnfinishedReminderEnabled() {
    return settingsBox.get('unfinished_reminder_enabled', defaultValue: true) as bool;
  }

  Future<void> setUnfinishedReminderEnabled(bool enabled) async {
    await settingsBox.put('unfinished_reminder_enabled', enabled);
  }

  Map<String, dynamic>? getUnfinishedTest() {
    final raw = progressBox.get('unfinished_test');
    if (raw == null) return null;
    return Map<String, dynamic>.from(raw as Map);
  }

  Future<void> saveUnfinishedTest({
    required String module,
    required String title,
    required int currentIndex,
    required int total,
  }) async {
    await progressBox.put('unfinished_test', {
      'module': module,
      'title': title,
      'current_index': currentIndex,
      'total': total,
      'saved_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> clearUnfinishedTest({String? module}) async {
    if (module == null) {
      await progressBox.delete('unfinished_test');
      return;
    }
    final existing = getUnfinishedTest();
    if (existing != null && existing['module'] == module) {
      await progressBox.delete('unfinished_test');
    }
  }

  // ── Questions ───────────────────────────────────────────────────────────

  Future<void> saveQuestions(List<Map<String, dynamic>> questions) async {
    final box = Hive.box<dynamic>(questionsBoxName);
    await box.clear();
    for (final q in questions) {
      await box.put(q['id'], q);
    }
    await setQuestionsSeeded(true);
  }

  @Deprecated('Use saveQuestions')
  Future<void> seedQuestions(List<Map<String, dynamic>> questions) =>
      saveQuestions(questions);

  Future<List<Map<String, dynamic>>> getAllQuestions() async {
    final box = Hive.box<dynamic>(questionsBoxName);
    return box.values.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<List<Map<String, dynamic>>> getQuestionsByCategory(String category) async {
    final all = await getAllQuestions();
    return all.where((q) => q['category'] == category).toList();
  }

  // ── Road signs ────────────────────────────────────────────────────────────

  Future<void> saveRoadSigns(List<Map<String, dynamic>> signs) async {
    final box = Hive.box<dynamic>(roadSignsBoxName);
    await box.clear();
    for (final sign in signs) {
      await box.put(sign['id'], sign);
    }
    await setRoadSignsSeeded(true);
  }

  @Deprecated('Use saveRoadSigns')
  Future<void> seedRoadSigns(List<Map<String, dynamic>> signs) =>
      saveRoadSigns(signs);

  Future<List<Map<String, dynamic>>> getAllRoadSigns() async {
    final box = Hive.box<dynamic>(roadSignsBoxName);
    return box.values.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<List<Map<String, dynamic>>> getRoadSignsByCategory(String category) async {
    final all = await getAllRoadSigns();
    return all.where((s) => s['category'] == category).toList();
  }

  // ── Highway code ──────────────────────────────────────────────────────────

  Future<void> saveHighwayCode(List<Map<String, dynamic>> entries) async {
    final box = Hive.box<dynamic>(highwayCodeBoxName);
    await box.clear();
    for (final entry in entries) {
      await box.put(entry['id'], entry);
    }
    await setHighwayCodeSeeded(true);
  }

  Future<List<Map<String, dynamic>>> getAllHighwayCodeEntries() async {
    final box = Hive.box<dynamic>(highwayCodeBoxName);
    final list = box.values.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    list.sort((a, b) => (a['order'] as int? ?? 0).compareTo(b['order'] as int? ?? 0));
    return list;
  }

  // ── Bookmarks ─────────────────────────────────────────────────────────────

  Future<List<String>> getBookmarkedQuestionIds() async {
    final list = bookmarksBox.get(_bookmarkQuestionIdsKey, defaultValue: <dynamic>[])
        as List<dynamic>;
    return list.map((e) => e.toString()).toList();
  }

  Future<void> toggleBookmark(String questionId) async {
    final list = await getBookmarkedQuestionIds();
    if (list.contains(questionId)) {
      list.remove(questionId);
    } else {
      list.add(questionId);
    }
    await bookmarksBox.put(_bookmarkQuestionIdsKey, list);
  }

  Future<bool> isQuestionBookmarked(String questionId) async {
    final list = await getBookmarkedQuestionIds();
    return list.contains(questionId);
  }

  // ── Progress ──────────────────────────────────────────────────────────────

  Future<Map<String, bool>> getAnsweredQuestionsHistory() async {
    final map = progressBox.get('answered_questions_history', defaultValue: <dynamic, dynamic>{})
        as Map<dynamic, dynamic>;
    return map.map((key, value) => MapEntry(key.toString(), value as bool));
  }

  Future<void> recordAnswer(String questionId, bool isCorrect) async {
    final map = progressBox.get('answered_questions_history', defaultValue: <dynamic, dynamic>{})
        as Map<dynamic, dynamic>;
    final newMap = Map<dynamic, dynamic>.from(map);
    newMap[questionId] = isCorrect;
    await progressBox.put('answered_questions_history', newMap);
  }

  Future<Map<String, bool>> getSignQuizHistory() async {
    final map = progressBox.get('sign_quiz_history', defaultValue: <dynamic, dynamic>{})
        as Map<dynamic, dynamic>;
    return map.map((key, value) => MapEntry(key.toString(), value as bool));
  }

  Future<void> recordSignQuizAnswer(String signId, bool isCorrect) async {
    final map = progressBox.get('sign_quiz_history', defaultValue: <dynamic, dynamic>{})
        as Map<dynamic, dynamic>;
    final newMap = Map<dynamic, dynamic>.from(map);
    newMap[signId] = isCorrect;
    await progressBox.put('sign_quiz_history', newMap);
  }

  Future<List<Map<String, dynamic>>> getTestSessionLogs() async {
    final list = progressBox.get('test_session_logs', defaultValue: <dynamic>[]) as List<dynamic>;
    return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<void> addTestSessionLog(Map<String, dynamic> log) async {
    final list = progressBox.get('test_session_logs', defaultValue: <dynamic>[]) as List<dynamic>;
    final updated = [log, ...list.map((e) => Map<String, dynamic>.from(e as Map))];
    await progressBox.put('test_session_logs', updated.take(50).toList());
  }

  // ── Generic ───────────────────────────────────────────────────────────────

  Future<void> put(String boxName, String key, dynamic value) async {
    final box = await _getOrOpenBox(boxName);
    await box.put(key, value);
  }

  Future<dynamic> get(String boxName, String key, {dynamic defaultValue}) async {
    final box = await _getOrOpenBox(boxName);
    return box.get(key, defaultValue: defaultValue);
  }

  Future<void> delete(String boxName, String key) async {
    final box = await _getOrOpenBox(boxName);
    await box.delete(key);
  }

  Future<void> clearBox(String boxName) async {
    final box = await _getOrOpenBox(boxName);
    await box.clear();
  }

  Future<void> _openBoxIfNeeded(String boxName) async {
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox<dynamic>(boxName);
    }
  }

  Future<Box<dynamic>> _getOrOpenBox(String boxName) async {
    await _openBoxIfNeeded(boxName);
    return Hive.box<dynamic>(boxName);
  }

  Future<void> _migrateLegacyBookmarks() async {
    final legacy = progressBox.get('bookmarked_question_ids');
    if (legacy == null) return;

    final current = await getBookmarkedQuestionIds();
    if (current.isEmpty && legacy is List && legacy.isNotEmpty) {
      await bookmarksBox.put(
        _bookmarkQuestionIdsKey,
        legacy.map((e) => e.toString()).toList(),
      );
    }
    await progressBox.delete('bookmarked_question_ids');
  }

  Future<void> _migrateLegacySeedFlags() async {
    if (settingsBox.get('questions_seeded') == null &&
        settingsBox.get('db_seeded') == true) {
      await settingsBox.put('questions_seeded', true);
    }
  }
}
