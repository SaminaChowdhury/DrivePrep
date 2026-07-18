class TestSessionLog {
  final String id;
  final String module;
  final String mode;
  final String? topic;
  final int correct;
  final int total;
  final DateTime completedAt;

  const TestSessionLog({
    required this.id,
    required this.module,
    required this.mode,
    required this.topic,
    required this.correct,
    required this.total,
    required this.completedAt,
  });

  double get scorePercent => total == 0 ? 0.0 : correct / total;

  bool get passed => module == 'theory' ? scorePercent >= 0.86 : scorePercent >= 0.7;

  factory TestSessionLog.fromJson(Map<String, dynamic> json) {
    return TestSessionLog(
      id: json['id'] as String,
      module: json['module'] as String,
      mode: json['mode'] as String,
      topic: json['topic'] as String?,
      correct: json['correct'] as int,
      total: json['total'] as int,
      completedAt: DateTime.parse(json['completedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'module': module,
        'mode': mode,
        'topic': topic,
        'correct': correct,
        'total': total,
        'completedAt': completedAt.toIso8601String(),
      };
}

class TopicPerformance {
  final String name;
  final String module;
  final double successRate;
  final int attempted;
  final int total;

  const TopicPerformance({
    required this.name,
    required this.module,
    required this.successRate,
    required this.attempted,
    required this.total,
  });

  bool get isWeak => attempted > 0 && successRate < 0.7;
}

class ProgressAnalytics {
  final int totalCompletedTests;
  final double averageScore;
  final int questionsAnswered;
  final int questionsCorrect;
  final List<TopicPerformance> weakTopics;
  final List<TopicPerformance> categoryPerformance;
  final List<TestSessionLog> recentSessions;
  final List<double> scoreTrend;

  const ProgressAnalytics({
    required this.totalCompletedTests,
    required this.averageScore,
    required this.questionsAnswered,
    required this.questionsCorrect,
    required this.weakTopics,
    required this.categoryPerformance,
    required this.recentSessions,
    required this.scoreTrend,
  });

  factory ProgressAnalytics.empty() {
    return const ProgressAnalytics(
      totalCompletedTests: 0,
      averageScore: 0,
      questionsAnswered: 0,
      questionsCorrect: 0,
      weakTopics: [],
      categoryPerformance: [],
      recentSessions: [],
      scoreTrend: [],
    );
  }
}
