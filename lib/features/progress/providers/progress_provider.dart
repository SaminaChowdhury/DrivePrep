import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/hive_service.dart';
import '../../signs/models/road_sign.dart';
import '../../signs/providers/signs_provider.dart';
import '../../theory/providers/theory_provider.dart';
import '../models/test_session_log.dart';

final testSessionLogsProvider =
    StateNotifierProvider<TestSessionLogsNotifier, List<TestSessionLog>>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return TestSessionLogsNotifier(hiveService);
});

class TestSessionLogsNotifier extends StateNotifier<List<TestSessionLog>> {
  final HiveService _hiveService;

  TestSessionLogsNotifier(this._hiveService) : super([]) {
    _load();
  }

  Future<void> _load() async {
    final raw = await _hiveService.getTestSessionLogs();
    state = raw.map(TestSessionLog.fromJson).toList();
  }

  Future<void> logSession({
    required String module,
    required String mode,
    required int correct,
    required int total,
    String? topic,
  }) async {
    final log = TestSessionLog(
      id: '${DateTime.now().millisecondsSinceEpoch}_$module',
      module: module,
      mode: mode,
      topic: topic,
      correct: correct,
      total: total,
      completedAt: DateTime.now(),
    );
    await _hiveService.addTestSessionLog(log.toJson());
    await _load();
  }
}

final progressAnalyticsProvider = Provider<ProgressAnalytics>((ref) {
  final sessions = ref.watch(testSessionLogsProvider);
  final categoryMap = ref.watch(categoryProgressProvider);
  final signHistory = ref.watch(signQuizHistoryProvider);
  final signsAsync = ref.watch(roadSignsProvider);

  final signs = signsAsync.maybeWhen(data: (s) => s, orElse: () => <RoadSign>[]);

  var questionsAnswered = 0;
  var questionsCorrect = 0;
  final categoryPerformance = <TopicPerformance>[];

  for (final progress in categoryMap.values) {
    if (progress.totalQuestions == 0) continue;
    questionsAnswered += progress.completedQuestions;
    questionsCorrect += progress.correctQuestions;
    categoryPerformance.add(
      TopicPerformance(
        name: progress.category,
        module: 'theory',
        successRate: progress.successRate,
        attempted: progress.completedQuestions,
        total: progress.totalQuestions,
      ),
    );
  }

  final signCategoryStats = <String, List<bool>>{};
  for (final sign in signs) {
    final result = signHistory[sign.id];
    if (result == null) continue;
    signCategoryStats.putIfAbsent(sign.category, () => []).add(result);
  }

  for (final entry in signCategoryStats.entries) {
    final correct = entry.value.where((v) => v).length;
    final attempted = entry.value.length;
    categoryPerformance.add(
      TopicPerformance(
        name: '${entry.key} Signs',
        module: 'signs',
        successRate: attempted == 0 ? 0 : correct / attempted,
        attempted: attempted,
        total: signs.where((s) => s.category == entry.key).length,
      ),
    );
  }

  categoryPerformance.sort((a, b) => a.successRate.compareTo(b.successRate));

  final weakTopics = categoryPerformance
      .where((t) => t.isWeak)
      .take(5)
      .toList();

  final sessionScores = sessions.map((s) => s.scorePercent).toList();
  final averageScore = sessionScores.isEmpty
      ? (questionsAnswered == 0 ? 0.0 : questionsCorrect / questionsAnswered)
      : sessionScores.reduce((a, b) => a + b) / sessionScores.length;

  final scoreTrend = sessions.take(7).toList().reversed.map((s) => s.scorePercent).toList();

  return ProgressAnalytics(
    totalCompletedTests: sessions.length,
    averageScore: averageScore,
    questionsAnswered: questionsAnswered,
    questionsCorrect: questionsCorrect,
    weakTopics: weakTopics,
    categoryPerformance: categoryPerformance,
    recentSessions: sessions.take(5).toList(),
    scoreTrend: scoreTrend,
  );
});
