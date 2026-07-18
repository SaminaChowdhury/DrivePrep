import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/signs_provider.dart';
import '../../progress/providers/progress_provider.dart';
import '../../../core/providers/notification_provider.dart';
import '../widgets/sign_image_card.dart';

class SignsQuizScreen extends ConsumerWidget {
  const SignsQuizScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizState = ref.watch(signQuizProvider);
    final theme = Theme.of(context);

    if (quizState.questions.isEmpty || quizState.currentQuestion == null) {
      return Scaffold(
        body: Center(
          child: Text(
            'No signs available for quiz.',
            style: GoogleFonts.outfit(fontSize: 16),
          ),
        ),
      );
    }

    final question = quizState.currentQuestion!;
    final selectedIdx = quizState.userAnswers[quizState.currentIndex];
    final isAnswered = quizState.isAnswered;
    final isLast = quizState.currentIndex >= quizState.questions.length - 1;
    final quizTitle = quizState.category ?? 'Sign Quiz';

    Future<bool> showExitWarning() async {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Quit quiz?', style: GoogleFonts.outfit(fontWeight: FontWeight.w800)),
          content: Text(
            'Your progress will be saved and you can get a reminder to finish later.',
            style: GoogleFonts.outfit(),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Stay')),
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Quit')),
          ],
        ),
      );
      return confirm ?? false;
    }

    Future<void> persistUnfinishedOnExit() async {
      await saveUnfinishedQuizReminder(
        ref,
        module: 'signs',
        title: quizTitle,
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
          quizTitle,
          style: GoogleFonts.outfit(fontWeight: FontWeight.w800),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${quizState.currentIndex + 1}/${quizState.questions.length}',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'What is the meaning of this sign?',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          SignImageCard(sign: question.sign, height: 180),
          const SizedBox(height: 8),
          Text(
            question.sign.title,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          ...List.generate(question.options.length, (index) {
            final isSelected = selectedIdx == index;
            final isCorrect = index == question.correctOptionIndex;
            Color? borderColor;
            Color? fillColor;

            if (isAnswered) {
              if (isCorrect) {
                borderColor = const Color(0xFF00A896);
                fillColor = const Color(0xFF00A896).withAlpha(25);
              } else if (isSelected) {
                borderColor = const Color(0xFFD90429);
                fillColor = const Color(0xFFD90429).withAlpha(20);
              }
            } else if (isSelected) {
              borderColor = theme.colorScheme.primary;
              fillColor = theme.colorScheme.primary.withAlpha(20);
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: fillColor ?? theme.cardTheme.color,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: isAnswered
                      ? null
                      : () => ref.read(signQuizProvider.notifier).selectAnswer(index),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: borderColor ??
                            theme.colorScheme.onSurface.withAlpha(20),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      question.options[index],
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 12),
          if (isAnswered)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (isLast) {
                    await clearUnfinishedQuizReminder(ref, module: 'signs');
                    ref.read(testSessionLogsProvider.notifier).logSession(
                          module: 'signs',
                          mode: quizState.category ?? 'quiz',
                          correct: quizState.correctCount,
                          total: quizState.questions.length,
                          topic: quizState.category,
                        );
                    if (context.mounted) {
                      context.pushReplacement('/signs-results');
                    }
                  } else {
                    ref.read(signQuizProvider.notifier).nextQuestion();
                  }
                },
                child: Text(isLast ? 'See Results' : 'Next Sign'),
              ),
            ),
        ],
      ),
    ),
    );
  }
}
