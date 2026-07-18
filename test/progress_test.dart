import 'package:flutter_test/flutter_test.dart';

import 'package:drive_prep/features/progress/models/test_session_log.dart';

void main() {
  test('TestSessionLog score and pass calculation', () {
    final theoryPass = TestSessionLog(
      id: '1',
      module: 'theory',
      mode: 'mock',
      topic: 'Alertness',
      correct: 43,
      total: 50,
      completedAt: DateTime(2026, 6, 8),
    );

    expect(theoryPass.scorePercent, closeTo(0.86, 0.001));
    expect(theoryPass.passed, isTrue);

    final signsFail = TestSessionLog(
      id: '2',
      module: 'signs',
      mode: 'quiz',
      topic: 'Regulatory',
      correct: 2,
      total: 5,
      completedAt: DateTime(2026, 6, 8),
    );

    expect(signsFail.passed, isFalse);
  });

  test('TestSessionLog json round trip', () {
    final original = TestSessionLog(
      id: 'abc',
      module: 'theory',
      mode: 'category',
      topic: 'Road Signs',
      correct: 8,
      total: 10,
      completedAt: DateTime(2026, 6, 8, 12, 30),
    );

    final restored = TestSessionLog.fromJson(original.toJson());
    expect(restored.id, original.id);
    expect(restored.correct, original.correct);
    expect(restored.completedAt, original.completedAt);
  });
}
