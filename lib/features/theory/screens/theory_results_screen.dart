import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../providers/theory_provider.dart';
import '../models/theory_question.dart';

class TheoryResultsScreen extends ConsumerWidget {
  const TheoryResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizState = ref.watch(theoryQuizProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final total = quizState.questions.length;
    final correct = quizState.correctCount;
    final wrong = total - correct;
    final percent = total == 0 ? 0.0 : correct / total;
    
    // DVSA Pass rate is 86% (43 out of 50). We apply this standard
    final isPassed = percent >= 0.86;

    return Scaffold(
      body: Container(
        color: theme.scaffoldBackgroundColor,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            physics: const BouncingScrollPhysics(),
            children: [
              // 1. Header Title
              Center(
                child: Text(
                  'Practice Finished',
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 2. Premium Circular Score Card
              Container(
                padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
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
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    CircularPercentIndicator(
                      radius: 65.0,
                      lineWidth: 12.0,
                      percent: percent,
                      center: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "${(percent * 100).toInt()}%",
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w900,
                              fontSize: 28,
                              color: isPassed ? const Color(0xFF00A896) : const Color(0xFFD90429),
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
                      circularStrokeCap: CircularStrokeCap.round,
                      backgroundColor: theme.colorScheme.onSurface.withAlpha(15),
                      progressColor: isPassed ? const Color(0xFF00A896) : const Color(0xFFD90429),
                    ),
                    const SizedBox(height: 20),
                    
                    // Pass/Fail badge status
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                      decoration: BoxDecoration(
                        color: isPassed
                            ? const Color(0xFF00A896).withAlpha(20)
                            : const Color(0xFFD90429).withAlpha(20),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: isPassed ? const Color(0xFF00A896) : const Color(0xFFD90429),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        isPassed ? 'PASSED (Target Met)' : 'FAILED (Target 86%)',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: isPassed ? const Color(0xFF00A896) : const Color(0xFFD90429),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 3. Stats widgets (Side-by-side metrics cards)
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context: context,
                      title: 'Correct',
                      value: '$correct',
                      icon: Icons.check_circle_rounded,
                      color: const Color(0xFF00A896),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildStatCard(
                      context: context,
                      title: 'Incorrect',
                      value: '$wrong',
                      icon: Icons.cancel_rounded,
                      color: const Color(0xFFD90429),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // 4. Question Review List Title
              Text(
                'Review Answers',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),

              // 5. Questions review list
              ...List.generate(
                quizState.questions.length,
                (index) {
                  final q = quizState.questions[index];
                  final userAns = quizState.userAnswers[index];
                  final correctAns = q.correctOptionIndex;
                  final isUserCorrect = userAns == correctAns;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.cardTheme.color,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isUserCorrect
                              ? const Color(0xFF00A896).withAlpha(40)
                              : const Color(0xFFD90429).withAlpha(40),
                          width: 1.2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                isUserCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                                color: isUserCorrect ? const Color(0xFF00A896) : const Color(0xFFD90429),
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  q.questionText,
                                  style: GoogleFonts.outfit(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 20),
                          Text(
                            'Your Answer: ${userAns != null && userAns < q.options.length ? q.options[userAns] : "No Answer Selected"}',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isUserCorrect ? const Color(0xFF00A896) : const Color(0xFFD90429),
                            ),
                          ),
                          if (!isUserCorrect) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Correct Answer: ${q.options[correctAns]}',
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF00A896),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // 6. Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Restart quiz with same questions list
                        final questions = List.from(quizState.questions);
                        ref.read(theoryQuizProvider.notifier).startQuiz(
                              questions.cast<TheoryQuestion>(),
                              quizState.mode,
                              category: quizState.category,
                            );
                        context.pushReplacement('/theory-quiz');
                      },
                      icon: const Icon(Icons.replay_rounded),
                      label: Text(
                        'Retry Quiz',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        side: BorderSide(color: theme.colorScheme.primary),
                        foregroundColor: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => context.go('/theory'),
                      icon: const Icon(Icons.dashboard_rounded),
                      label: Text(
                        'Dashboard',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Mini metrics card builder
  Widget _buildStatCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? Colors.white.withAlpha(15) : Colors.black.withAlpha(10),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  color: theme.colorScheme.onSurface.withAlpha(120),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
