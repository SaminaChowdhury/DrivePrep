import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/hive_service.dart';
import '../../../core/services/offline_sync_service.dart';
import '../models/theory_question.dart';

// 1. Provider to retrieve the overall list of questions (Hive-first)
final theoryQuestionsProvider = FutureProvider<List<TheoryQuestion>>((ref) async {
  final hiveService = ref.watch(hiveServiceProvider);
  final sync = ref.read(offlineSyncServiceProvider);

  var list = await hiveService.getAllQuestions();
  if (list.isEmpty) {
    await sync.syncQuestions();
    list = await hiveService.getAllQuestions();
  }

  return list.map((json) => TheoryQuestion.fromJson(json)).toList();
});

// 2. Notifier and Provider for Question Bookmarks
final bookmarksProvider = StateNotifierProvider<BookmarksNotifier, List<String>>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return BookmarksNotifier(hiveService);
});

class BookmarksNotifier extends StateNotifier<List<String>> {
  final HiveService _hiveService;

  BookmarksNotifier(this._hiveService) : super([]) {
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    state = await _hiveService.getBookmarkedQuestionIds();
  }

  Future<void> toggleBookmark(String questionId) async {
    await _hiveService.toggleBookmark(questionId);
    await _loadBookmarks();
  }
}

// 3. Notifier and Provider for Answered Questions History
final answeredQuestionsProvider = StateNotifierProvider<AnsweredQuestionsNotifier, Map<String, bool>>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return AnsweredQuestionsNotifier(hiveService);
});

class AnsweredQuestionsNotifier extends StateNotifier<Map<String, bool>> {
  final HiveService _hiveService;

  AnsweredQuestionsNotifier(this._hiveService) : super({}) {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    state = await _hiveService.getAnsweredQuestionsHistory();
  }

  Future<void> recordAnswer(String questionId, bool isCorrect) async {
    await _hiveService.recordAnswer(questionId, isCorrect);
    await _loadHistory();
  }

  Future<void> clearHistory() async {
    await _hiveService.clearBox(HiveService.progressBoxName);
    state = {};
  }
}

// 4. Model and Provider for Category-wise Progress
class CategoryProgress {
  final String category;
  final int totalQuestions;
  final int completedQuestions;
  final int correctQuestions;

  CategoryProgress({
    required this.category,
    required this.totalQuestions,
    required this.completedQuestions,
    required this.correctQuestions,
  });

  double get completionRate => totalQuestions == 0 ? 0.0 : completedQuestions / totalQuestions;
  double get successRate => completedQuestions == 0 ? 0.0 : correctQuestions / completedQuestions;
}

final categoryProgressProvider = Provider<Map<String, CategoryProgress>>((ref) {
  final questionsAsync = ref.watch(theoryQuestionsProvider);
  final answeredMap = ref.watch(answeredQuestionsProvider);

  return questionsAsync.maybeWhen(
    data: (questions) {
      final map = <String, CategoryProgress>{};
      
      // Initialize categories first with 0 values to ensure all 14 categories show on dashboard
      const categories = [
        'Alertness', 'Attitude', 'Safety and Your Vehicle', 'Safety Margins',
        'Hazard Awareness', 'Vulnerable Road Users', 'Other Types of Vehicle',
        'Vehicle Handling', 'Motorway Rules', 'Rules of the Road',
        'Road and Traffic Signs', 'Essential Documents',
        'Incidents, Accidents and Emergencies', 'Pedestrian Crossings'
      ];

      for (var cat in categories) {
        map[cat] = CategoryProgress(
          category: cat,
          totalQuestions: 0,
          completedQuestions: 0,
          correctQuestions: 0,
        );
      }

      // Populate counts
      for (var q in questions) {
        final progress = map[q.category] ?? CategoryProgress(
          category: q.category,
          totalQuestions: 0,
          completedQuestions: 0,
          correctQuestions: 0,
        );
        final isCompleted = answeredMap.containsKey(q.id);
        final isCorrect = answeredMap[q.id] ?? false;

        map[q.category] = CategoryProgress(
          category: q.category,
          totalQuestions: progress.totalQuestions + 1,
          completedQuestions: progress.completedQuestions + (isCompleted ? 1 : 0),
          correctQuestions: progress.correctQuestions + (isCorrect ? 1 : 0),
        );
      }
      return map;
    },
    orElse: () => {},
  );
});

// 5. State Model for active Quiz session
class QuizState {
  final List<TheoryQuestion> questions;
  final int currentIndex;
  final Map<int, int> userAnswers; // Map of question index -> selected option index
  final bool isAnswered;
  final String mode; // 'category', 'mock', 'bookmarks'
  final String? category;

  QuizState({
    required this.questions,
    required this.currentIndex,
    required this.userAnswers,
    required this.isAnswered,
    required this.mode,
    this.category,
  });

  factory QuizState.empty() {
    return QuizState(
      questions: [],
      currentIndex: 0,
      userAnswers: {},
      isAnswered: false,
      mode: 'category',
    );
  }

  QuizState copyWith({
    List<TheoryQuestion>? questions,
    int? currentIndex,
    Map<int, int>? userAnswers,
    bool? isAnswered,
    String? mode,
    String? category,
  }) {
    return QuizState(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      userAnswers: userAnswers ?? this.userAnswers,
      isAnswered: isAnswered ?? this.isAnswered,
      mode: mode ?? this.mode,
      category: category ?? this.category,
    );
  }

  TheoryQuestion get currentQuestion => questions[currentIndex];
  int? get selectedAnswer => userAnswers[currentIndex];
  bool get isCompleted => currentIndex >= questions.length - 1 && isAnswered;

  int get correctCount {
    int count = 0;
    userAnswers.forEach((idx, selected) {
      if (idx < questions.length && selected == questions[idx].correctOptionIndex) {
        count++;
      }
    });
    return count;
  }
}

// 6. State Notifier and Provider for Active Quiz Session
final theoryQuizProvider = StateNotifierProvider<TheoryQuizNotifier, QuizState>((ref) {
  return TheoryQuizNotifier(ref);
});

class TheoryQuizNotifier extends StateNotifier<QuizState> {
  final Ref _ref;

  TheoryQuizNotifier(this._ref) : super(QuizState.empty());

  void startQuiz(List<TheoryQuestion> questions, String mode, {String? category}) {
    state = QuizState(
      questions: questions,
      currentIndex: 0,
      userAnswers: {},
      isAnswered: false,
      mode: mode,
      category: category,
    );
  }

  void selectAnswer(int optionIndex) {
    if (state.isAnswered) return; // Allow selecting only once

    final updatedAnswers = Map<int, int>.from(state.userAnswers);
    updatedAnswers[state.currentIndex] = optionIndex;

    final currentQuestion = state.currentQuestion;
    final isCorrect = optionIndex == currentQuestion.correctOptionIndex;

    // Persist answered history state in Hive
    _ref.read(answeredQuestionsProvider.notifier).recordAnswer(currentQuestion.id, isCorrect);

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

  void toggleBookmark() {
    if (state.questions.isEmpty) return;
    final questionId = state.currentQuestion.id;
    _ref.read(bookmarksProvider.notifier).toggleBookmark(questionId);
  }
}
