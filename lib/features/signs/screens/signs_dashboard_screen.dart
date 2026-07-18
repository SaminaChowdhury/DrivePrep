import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../data/default_signs.dart';
import '../models/road_sign.dart';
import '../providers/signs_provider.dart';
import '../widgets/sign_image_card.dart';

class SignsDashboardScreen extends ConsumerWidget {
  const SignsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final signsAsync = ref.watch(roadSignsProvider);
    final quizHistory = ref.watch(signQuizHistoryProvider);

    void startFlashcards(List<RoadSign> signs, {String? category}) {
      if (signs.isEmpty) return;
      ref.read(signFlashcardSessionProvider.notifier).state =
          SignFlashcardSession(signs: signs);
      context.push('/signs-flashcards');
    }

    void startQuiz(List<RoadSign> signs, {String? category}) {
      if (signs.isEmpty) return;
      ref.read(signQuizProvider.notifier).startQuiz(signs, category: category);
      context.push('/signs-quiz');
    }

    return Scaffold(
      body: Container(
        color: theme.scaffoldBackgroundColor,
        child: SafeArea(
          child: signsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(
              child: Text(
                'Failed to load signs: $err',
                style: GoogleFonts.outfit(color: theme.colorScheme.error),
              ),
            ),
            data: (allSigns) {
              final learnedCount = quizHistory.keys.length;
              final correctCount =
                  quizHistory.values.where((correct) => correct).length;
              final progressRate = allSigns.isEmpty
                  ? 0.0
                  : learnedCount / allSigns.length;
              final successRate =
                  learnedCount == 0 ? 0.0 : correctCount / learnedCount;

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => context.pop(),
                            icon: const Icon(Icons.arrow_back_rounded),
                          ),
                          Expanded(
                            child: Text(
                              'Road Signs',
                              style: GoogleFonts.outfit(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark
                                ? [const Color(0xFF4A1942), const Color(0xFFE91E63)]
                                : [const Color(0xFFE91E63), const Color(0xFFFF6090)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          children: [
                            CircularPercentIndicator(
                              radius: 52,
                              lineWidth: 10,
                              percent: progressRate.clamp(0.0, 1.0),
                              center: Text(
                                '${allSigns.length}',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 22,
                                ),
                              ),
                              progressColor: Colors.white,
                              backgroundColor: Colors.white.withAlpha(50),
                              circularStrokeCap: CircularStrokeCap.round,
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Offline Sign Library',
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '$learnedCount quizzed • ${(successRate * 100).toInt()}% accuracy',
                                    style: GoogleFonts.outfit(
                                      color: Colors.white.withAlpha(210),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                      child: Text(
                        'Study Modes',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: _ModeButton(
                              title: 'Flashcards',
                              subtitle: 'Flip to learn meanings',
                              icon: Icons.style_rounded,
                              color: const Color(0xFF9C27B0),
                              onTap: () => startFlashcards(allSigns),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ModeButton(
                              title: 'Quiz',
                              subtitle: 'Test your knowledge',
                              icon: Icons.quiz_rounded,
                              color: const Color(0xFFE91E63),
                              onTap: () => startQuiz(allSigns),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                      child: Text(
                        'Browse by Category',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final category = roadSignCategories[index];
                        final categorySigns = allSigns
                            .where((s) => s.category == category)
                            .toList();
                        final colors = {
                          'Regulatory': const Color(0xFFD90429),
                          'Warning': const Color(0xFFFF8C42),
                          'Information': const Color(0xFF0072BC),
                        };

                        return Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                          child: _CategoryCard(
                            category: category,
                            count: categorySigns.length,
                            color: colors[category] ?? theme.colorScheme.primary,
                            onFlashcards: () =>
                                startFlashcards(categorySigns, category: category),
                            onQuiz: () => startQuiz(categorySigns, category: category),
                          ),
                        );
                      },
                      childCount: roadSignCategories.length,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                      child: Text(
                        'All Signs',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final sign = allSigns[index];
                        final wasCorrect = quizHistory[sign.id];

                        return Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                          child: Material(
                            color: theme.cardTheme.color,
                            borderRadius: BorderRadius.circular(16),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                startFlashcards(allSigns, category: sign.category);
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 72,
                                      height: 72,
                                      child: SignImageCard(sign: sign, height: 72),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            sign.title,
                                            style: GoogleFonts.outfit(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            sign.category,
                                            style: GoogleFonts.outfit(
                                              fontSize: 11,
                                              color: theme.colorScheme.primary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            sign.meaning,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.outfit(
                                              fontSize: 11,
                                              color: theme.colorScheme.onSurface
                                                  .withAlpha(140),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (wasCorrect != null)
                                      Icon(
                                        wasCorrect
                                            ? Icons.check_circle_rounded
                                            : Icons.cancel_rounded,
                                        color: wasCorrect
                                            ? const Color(0xFF00A896)
                                            : const Color(0xFFD90429),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: allSigns.length,
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ModeButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.cardTheme.color,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withAlpha(50)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 10),
              Text(
                title,
                style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 15),
              ),
              Text(
                subtitle,
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  color: theme.colorScheme.onSurface.withAlpha(140),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String category;
  final int count;
  final Color color;
  final VoidCallback onFlashcards;
  final VoidCallback onQuiz;

  const _CategoryCard({
    required this.category,
    required this.count,
    required this.color,
    required this.onFlashcards,
    required this.onQuiz,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.traffic_rounded, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
                ),
                Text(
                  '$count signs',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withAlpha(140),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onFlashcards,
            icon: const Icon(Icons.style_outlined),
            tooltip: 'Flashcards',
          ),
          IconButton(
            onPressed: onQuiz,
            icon: const Icon(Icons.quiz_outlined),
            tooltip: 'Quiz',
          ),
        ],
      ),
    );
  }
}
