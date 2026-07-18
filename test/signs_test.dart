import 'package:flutter_test/flutter_test.dart';

import 'package:drive_prep/features/signs/data/default_signs.dart';
import 'package:drive_prep/features/signs/models/road_sign.dart';
import 'package:drive_prep/features/signs/providers/signs_provider.dart';

void main() {
  test('RoadSign fromJson and toJson round trip', () {
    final sign = defaultRoadSigns.first;
    final restored = RoadSign.fromJson(sign.toJson());

    expect(restored.id, sign.id);
    expect(restored.title, sign.title);
    expect(restored.meaning, sign.meaning);
    expect(restored.category, sign.category);
    expect(restored.imageAssetPath, sign.imageAssetPath);
  });

  test('buildSignQuizQuestions creates four options with one correct answer', () {
    final questions = buildSignQuizQuestions(defaultRoadSigns.take(4).toList());

    expect(questions.length, 4);
    for (final question in questions) {
      expect(question.options.length, 4);
      expect(question.options[question.correctOptionIndex], question.sign.meaning);
    }
  });
}
