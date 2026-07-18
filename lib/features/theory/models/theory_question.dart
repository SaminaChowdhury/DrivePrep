class TheoryQuestion {
  final String id;
  final String category;
  final String questionText;
  final List<String> options;
  final int correctOptionIndex;
  final String explanation;

  TheoryQuestion({
    required this.id,
    required this.category,
    required this.questionText,
    required this.options,
    required this.correctOptionIndex,
    required this.explanation,
  });

  factory TheoryQuestion.fromJson(Map<String, dynamic> json) {
    return TheoryQuestion(
      id: json['id'] as String,
      category: json['category'] as String,
      questionText: json['questionText'] as String,
      options: List<String>.from(json['options'] as List),
      correctOptionIndex: json['correctOptionIndex'] as int,
      explanation: json['explanation'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'questionText': questionText,
      'options': options,
      'correctOptionIndex': correctOptionIndex,
      'explanation': explanation,
    };
  }
}
