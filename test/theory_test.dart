import 'package:flutter_test/flutter_test.dart';
import 'package:drive_prep/features/theory/models/theory_question.dart';

void main() {
  test('TheoryQuestion fromJson and toJson verification', () {
    final json = {
      'id': 'test_1',
      'category': 'Alertness',
      'questionText': 'What should you do?',
      'options': ['Option A', 'Option B', 'Option C', 'Option D'],
      'correctOptionIndex': 0,
      'explanation': 'Because option A is correct.'
    };

    final question = TheoryQuestion.fromJson(json);

    expect(question.id, 'test_1');
    expect(question.category, 'Alertness');
    expect(question.questionText, 'What should you do?');
    expect(question.options.length, 4);
    expect(question.options[0], 'Option A');
    expect(question.correctOptionIndex, 0);
    expect(question.explanation, 'Because option A is correct.');

    final serialized = question.toJson();
    expect(serialized['id'], 'test_1');
    expect(serialized['category'], 'Alertness');
    expect(serialized['correctOptionIndex'], 0);
  });
}
