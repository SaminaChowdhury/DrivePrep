import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/hive_service.dart';
import '../../../core/services/offline_sync_service.dart';
import '../models/road_sign.dart';

final roadSignsProvider = FutureProvider<List<RoadSign>>((ref) async {
  final hiveService = ref.watch(hiveServiceProvider);
  final sync = ref.read(offlineSyncServiceProvider);

  var list = await hiveService.getAllRoadSigns();
  if (list.isEmpty) {
    await sync.syncRoadSigns();
    list = await hiveService.getAllRoadSigns();
  }

  return list.map((json) => RoadSign.fromJson(json)).toList()
    ..sort((a, b) => a.title.compareTo(b.title));
});

final signQuizHistoryProvider =
    StateNotifierProvider<SignQuizHistoryNotifier, Map<String, bool>>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return SignQuizHistoryNotifier(hiveService);
});

class SignQuizHistoryNotifier extends StateNotifier<Map<String, bool>> {
  final HiveService _hiveService;

  SignQuizHistoryNotifier(this._hiveService) : super({}) {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    state = await _hiveService.getSignQuizHistory();
  }

  Future<void> recordAnswer(String signId, bool isCorrect) async {
    await _hiveService.recordSignQuizAnswer(signId, isCorrect);
    await _loadHistory();
  }
}

class SignQuizQuestion {
  final RoadSign sign;
  final List<String> options;
  final int correctOptionIndex;

  const SignQuizQuestion({
    required this.sign,
    required this.options,
    required this.correctOptionIndex,
  });
}

List<SignQuizQuestion> buildSignQuizQuestions(List<RoadSign> signs) {
  final random = Random();
  return signs.map((sign) {
    final distractors = signs
        .where((s) => s.id != sign.id)
        .map((s) => s.meaning)
        .toList()
      ..shuffle(random);

    final options = [sign.meaning, ...distractors.take(3)];
    options.shuffle(random);

    return SignQuizQuestion(
      sign: sign,
      options: options,
      correctOptionIndex: options.indexOf(sign.meaning),
    );
  }).toList();
}

class SignQuizState {
  final List<SignQuizQuestion> questions;
  final int currentIndex;
  final Map<int, int> userAnswers;
  final bool isAnswered;
  final String? category;

  const SignQuizState({
    required this.questions,
    required this.currentIndex,
    required this.userAnswers,
    required this.isAnswered,
    this.category,
  });

  factory SignQuizState.empty() {
    return const SignQuizState(
      questions: [],
      currentIndex: 0,
      userAnswers: {},
      isAnswered: false,
    );
  }

  SignQuizQuestion? get currentQuestion =>
      currentIndex < questions.length ? questions[currentIndex] : null;

  bool get isFinished =>
      questions.isNotEmpty && currentIndex >= questions.length - 1 && isAnswered;

  int get correctCount {
    var count = 0;
    userAnswers.forEach((index, selected) {
      if (index < questions.length &&
          selected == questions[index].correctOptionIndex) {
        count++;
      }
    });
    return count;
  }

  SignQuizState copyWith({
    List<SignQuizQuestion>? questions,
    int? currentIndex,
    Map<int, int>? userAnswers,
    bool? isAnswered,
    String? category,
  }) {
    return SignQuizState(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      userAnswers: userAnswers ?? this.userAnswers,
      isAnswered: isAnswered ?? this.isAnswered,
      category: category ?? this.category,
    );
  }
}

final signQuizProvider = StateNotifierProvider<SignQuizNotifier, SignQuizState>((ref) {
  return SignQuizNotifier(ref);
});

class SignQuizNotifier extends StateNotifier<SignQuizState> {
  final Ref _ref;

  SignQuizNotifier(this._ref) : super(SignQuizState.empty());

  void startQuiz(List<RoadSign> signs, {String? category}) {
    final questions = buildSignQuizQuestions(signs)..shuffle(Random());
    state = SignQuizState(
      questions: questions,
      currentIndex: 0,
      userAnswers: {},
      isAnswered: false,
      category: category,
    );
  }

  void selectAnswer(int optionIndex) {
    if (state.isAnswered || state.currentQuestion == null) return;

    final question = state.currentQuestion!;
    final updatedAnswers = Map<int, int>.from(state.userAnswers);
    updatedAnswers[state.currentIndex] = optionIndex;

    final isCorrect = optionIndex == question.correctOptionIndex;
    _ref.read(signQuizHistoryProvider.notifier).recordAnswer(question.sign.id, isCorrect);

    state = state.copyWith(
      userAnswers: updatedAnswers,
      isAnswered: true,
    );
  }

  void nextQuestion() {
    if (!state.isAnswered) return;
    if (state.currentIndex < state.questions.length - 1) {
      state = state.copyWith(
        currentIndex: state.currentIndex + 1,
        isAnswered: false,
      );
    }
  }

  void reset() {
    state = SignQuizState.empty();
  }
}

class SignFlashcardSession {
  final List<RoadSign> signs;
  final int initialIndex;

  const SignFlashcardSession({
    required this.signs,
    this.initialIndex = 0,
  });
}

final signFlashcardSessionProvider = StateProvider<SignFlashcardSession?>((ref) => null);
