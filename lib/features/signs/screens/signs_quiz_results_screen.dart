import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../providers/signs_provider.dart';
import '../widgets/sign_image_card.dart';

class SignsQuizResultsScreen extends ConsumerWidget {
  const SignsQuizResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizState = ref.watch(signQuizProvider);
    final theme = Theme.of(context);

    final total = quizState.questions.length;
    final correct = quizState.correctCount;
    final rate = total == 0 ? 0.0 : correct / total;
    final isPassed = rate >= 0.7;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Text(
                'Quiz Complete',
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  CircularPercentIndicator(
                    radius: 65,
                    lineWidth: 12,
                    percent: rate.clamp(0.0, 1.0),
                    center: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${(rate * 100).toInt()}%',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w900,
                            fontSize: 28,
                            color: isPassed
                                ? const Color(0xFF00A896)
                                : const Color(0xFFD90429),
                          ),
                        ),
                        Text(
                          '$correct / $total',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: theme.colorScheme.onSurface.withAlpha(150),
                          ),
                        ),
                      ],
                    ),
                    progressColor:
                        isPassed ? const Color(0xFF00A896) : const Color(0xFFD90429),
                    backgroundColor: theme.colorScheme.onSurface.withAlpha(15),
                    circularStrokeCap: CircularStrokeCap.round,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isPassed ? 'Great work!' : 'Keep practising (target 70%)',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Review',
              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            ...List.generate(quizState.questions.length, (index) {
              final question = quizState.questions[index];
              final selected = quizState.userAnswers[index];
              final isCorrect = selected == question.correctOptionIndex;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: (isCorrect
                              ? const Color(0xFF00A896)
                              : const Color(0xFFD90429))
                          .withAlpha(50),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SignImageCard(sign: question.sign, height: 100),
                      const SizedBox(height: 12),
                      Text(
                        question.sign.title,
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        question.sign.meaning,
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withAlpha(160),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      final signs =
                          quizState.questions.map((q) => q.sign).toList();
                      ref.read(signQuizProvider.notifier).startQuiz(
                            signs,
                            category: quizState.category,
                          );
                      context.pushReplacement('/signs-quiz');
                    },
                    icon: const Icon(Icons.replay_rounded),
                    label: const Text('Retry'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ref.read(signQuizProvider.notifier).reset();
                      context.go('/signs');
                    },
                    icon: const Icon(Icons.dashboard_rounded),
                    label: const Text('Dashboard'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
