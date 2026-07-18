import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/theory_provider.dart';
import '../../progress/providers/progress_provider.dart';
import '../../../core/providers/notification_provider.dart';

class TheoryQuizScreen extends ConsumerWidget {
  const TheoryQuizScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizState = ref.watch(theoryQuizProvider);
    final bookmarks = ref.watch(bookmarksProvider);
    
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (quizState.questions.isEmpty) {
      return Scaffold(
        body: Center(
          child: Text(
            'No questions available.',
            style: GoogleFonts.outfit(fontSize: 18),
          ),
        ),
      );
    }

    final question = quizState.currentQuestion;
    final isBookmarked = bookmarks.contains(question.id);
    final isAnswered = quizState.isAnswered;
    final selectedIdx = quizState.selectedAnswer;

    // Helper: title based on quiz mode
    String getTitle() {
      if (quizState.mode == 'mock') return 'Mock Exam';
      if (quizState.mode == 'bookmarks') return 'Bookmarked Quiz';
      return quizState.category ?? 'Theory Quiz';
    }

    // Confirmation dialog before exiting active session
    Future<bool> showExitWarning() async {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Quit Practice?',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
          ),
          content: Text(
            'Your current progress in this session will be lost. Are you sure you want to exit?',
            style: GoogleFonts.outfit(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Cancel',
                style: GoogleFonts.outfit(color: theme.colorScheme.primary, fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Text(
                'Quit',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
      return confirm ?? false;
    }

    Future<void> persistUnfinishedOnExit() async {
      await saveUnfinishedQuizReminder(
        ref,
        module: 'theory',
        title: getTitle(),
        currentIndex: quizState.currentIndex,
        total: quizState.questions.length,
      );
    }

    return WillPopScope(
      onWillPop: () async {
        final exit = await showExitWarning();
        if (exit) {
          await persistUnfinishedOnExit();
        }
        return exit;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () async {
              final exit = await showExitWarning();
              if (exit && context.mounted) {
                await persistUnfinishedOnExit();
                context.pop();
              }
            },
          ),
          title: Text(
            getTitle(),
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: theme.colorScheme.onSurface,
            ),
          ),
          actions: [
            // Bookmark icon
            IconButton(
              icon: Icon(
                isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                color: isBookmarked ? theme.colorScheme.tertiary : theme.colorScheme.onSurface.withAlpha(150),
                size: 26,
              ),
              onPressed: () {
                ref.read(theoryQuizProvider.notifier).toggleBookmark();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isBookmarked ? 'Removed from bookmarks!' : 'Added to bookmarks!',
                    ),
                    duration: const Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              },
            ),
            const SizedBox(width: 10),
          ],
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          color: theme.scaffoldBackgroundColor,
          child: SafeArea(
            child: Column(
              children: [
                // Linear progress indicator at the top
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: (quizState.currentIndex + 1) / quizState.questions.length,
                            minHeight: 6,
                            backgroundColor: theme.colorScheme.primary.withAlpha(20),
                            valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        '${quizState.currentIndex + 1}/${quizState.questions.length}',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface.withAlpha(180),
                        ),
                      ),
                    ],
                  ),
                ),

                // Core scrollable contents (Question, options, explanation)
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      // Question text card
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: theme.cardTheme.color,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isDark ? Colors.white.withAlpha(15) : Colors.black.withAlpha(10),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(isDark ? 20 : 5),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Text(
                          question.questionText,
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                            height: 1.4,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // 4 options
                      ...List.generate(
                        question.options.length,
                        (index) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildOptionButton(
                            context: context,
                            optionIndex: index,
                            optionText: question.options[index],
                            correctIndex: question.correctOptionIndex,
                            selectedIndex: selectedIdx,
                            isAnswered: isAnswered,
                            onTap: () {
                              ref.read(theoryQuizProvider.notifier).selectAnswer(index);
                            },
                          ),
                        ),
                      ),

                      // Dynamic Explanation card
                      if (isAnswered) ...[
                        const SizedBox(height: 18),
                        AnimatedOpacity(
                          opacity: isAnswered ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 300),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: selectedIdx == question.correctOptionIndex
                                  ? const Color(0xFF00A896).withAlpha(12)
                                  : const Color(0xFFD90429).withAlpha(12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: selectedIdx == question.correctOptionIndex
                                    ? const Color(0xFF00A896).withAlpha(100)
                                    : const Color(0xFFD90429).withAlpha(100),
                                width: 1.2,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      selectedIdx == question.correctOptionIndex
                                          ? Icons.check_circle_rounded
                                          : Icons.cancel_rounded,
                                      color: selectedIdx == question.correctOptionIndex
                                          ? const Color(0xFF00A896)
                                          : const Color(0xFFD90429),
                                      size: 22,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      selectedIdx == question.correctOptionIndex
                                          ? 'Correct Answer!'
                                          : 'Incorrect Answer',
                                      style: GoogleFonts.outfit(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: selectedIdx == question.correctOptionIndex
                                            ? const Color(0xFF00A896)
                                            : const Color(0xFFD90429),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  question.explanation,
                                  style: GoogleFonts.outfit(
                                    fontSize: 13,
                                    color: theme.colorScheme.onSurface,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Primary Next / Complete CTA
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: !isAnswered
                          ? null
                          : () async {
                              if (quizState.isCompleted) {
                                await clearUnfinishedQuizReminder(ref, module: 'theory');
                                ref.read(testSessionLogsProvider.notifier).logSession(
                                      module: 'theory',
                                      mode: quizState.mode,
                                      correct: quizState.correctCount,
                                      total: quizState.questions.length,
                                      topic: quizState.category,
                                    );
                                if (context.mounted) {
                                  context.pushReplacement('/theory-results');
                                }
                              } else {
                                // Load next question
                                ref.read(theoryQuizProvider.notifier).nextQuestion();
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: theme.colorScheme.primary.withAlpha(40),
                        disabledForegroundColor: theme.colorScheme.onSurface.withAlpha(80),
                        elevation: isAnswered ? 3 : 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        quizState.isCompleted
                            ? 'Finish & View Results'
                            : 'Next Question',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Interactive Option Card Builder with instant colors
  Widget _buildOptionButton({
    required BuildContext context,
    required int optionIndex,
    required String optionText,
    required int correctIndex,
    required int? selectedIndex,
    required bool isAnswered,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color buttonBgColor = theme.cardTheme.color!;
    Color borderCol = isDark ? Colors.white.withAlpha(15) : Colors.black.withAlpha(10);
    Color textCol = theme.colorScheme.onSurface;
    double borderW = 1.0;

    // Evaluate colors after answer selection
    if (isAnswered) {
      if (optionIndex == correctIndex) {
        // Correct option always highlighted in Green
        buttonBgColor = const Color(0xFF00A896).withAlpha(18);
        borderCol = const Color(0xFF00A896);
        textCol = const Color(0xFF00A896);
        borderW = 1.8;
      } else if (optionIndex == selectedIndex) {
        // Selected incorrect option highlighted in Red
        buttonBgColor = const Color(0xFFD90429).withAlpha(18);
        borderCol = const Color(0xFFD90429);
        textCol = const Color(0xFFD90429);
        borderW = 1.8;
      } else {
        // Unselected incorrect options faded out
        textCol = theme.colorScheme.onSurface.withAlpha(100);
      }
    } else {
      // Normal hover/selected styling
      if (selectedIndex == optionIndex) {
        buttonBgColor = theme.colorScheme.primary.withAlpha(15);
        borderCol = theme.colorScheme.primary;
        textCol = theme.colorScheme.primary;
        borderW = 1.8;
      }
    }

    return InkWell(
      onTap: isAnswered ? null : onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: buttonBgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderCol,
            width: borderW,
          ),
          boxShadow: [
            if (selectedIndex == optionIndex && !isAnswered)
              BoxShadow(
                color: theme.colorScheme.primary.withAlpha(30),
                blurRadius: 8,
                offset: const Offset(0, 3),
              )
          ],
        ),
        child: Row(
          children: [
            // Styled Letter/Check Indicator
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isAnswered && optionIndex == correctIndex
                    ? const Color(0xFF00A896)
                    : isAnswered && optionIndex == selectedIndex
                        ? const Color(0xFFD90429)
                        : selectedIndex == optionIndex
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withAlpha(15),
              ),
              child: Center(
                child: isAnswered && optionIndex == correctIndex
                    ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                    : isAnswered && optionIndex == selectedIndex
                        ? const Icon(Icons.close_rounded, color: Colors.white, size: 16)
                        : Text(
                            String.fromCharCode(65 + optionIndex), // A, B, C, D
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              color: selectedIndex == optionIndex ? Colors.white : theme.colorScheme.onSurface,
                            ),
                          ),
              ),
            ),
            const SizedBox(width: 16),
            // Option Content Text
            Expanded(
              child: Text(
                optionText,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textCol,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
