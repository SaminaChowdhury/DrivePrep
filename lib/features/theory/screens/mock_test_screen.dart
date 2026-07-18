import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/theory_provider.dart';
import '../models/theory_question.dart';

class MockTestScreen extends ConsumerWidget {
  const MockTestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final questionsAsync = ref.watch(theoryQuestionsProvider);

    void startMock(List<TheoryQuestion> allQuestions, {required int count, required String label}) {
      final shuffled = List<TheoryQuestion>.from(allQuestions)..shuffle();
      final selected = shuffled.take(count.clamp(1, allQuestions.length)).toList();
      ref.read(theoryQuizProvider.notifier).startQuiz(selected, 'mock', category: label);
      context.push('/theory-quiz');
    }

    return Scaffold(
      body: Container(
        color: theme.scaffoldBackgroundColor,
        child: SafeArea(
          child: questionsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Failed to load: $err')),
            data: (allQuestions) {
              final fullCount = allQuestions.length;

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new_rounded),
                            onPressed: () => context.go('/home'),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Mock Test',
                            style: GoogleFonts.outfit(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
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
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark
                                ? [const Color(0xFF004D40), const Color(0xFF00695C)]
                                : [const Color(0xFF00A896), const Color(0xFF26C6DA)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00A896).withAlpha(isDark ? 40 : 80),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withAlpha(30),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.assignment_turned_in_rounded, color: Colors.white, size: 28),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'DVSA Mock Exam',
                                        style: GoogleFonts.outfit(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        'Timed simulation • Pass mark 43/50',
                                        style: GoogleFonts.outfit(
                                          fontSize: 12,
                                          color: Colors.white.withAlpha(200),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                _StatChip(label: 'Questions', value: '$fullCount available'),
                                const SizedBox(width: 10),
                                _StatChip(label: 'Time', value: '57 min'),
                              ],
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
                        'Choose Exam Length',
                        style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _MockOptionCard(
                          title: 'Full Mock Exam',
                          subtitle: 'All $fullCount questions — closest to the real test',
                          icon: Icons.school_rounded,
                          color: const Color(0xFF00A896),
                          badge: 'Recommended',
                          onTap: () => startMock(allQuestions, count: fullCount, label: 'Full Mock'),
                        ),
                        const SizedBox(height: 12),
                        _MockOptionCard(
                          title: 'Standard Mock',
                          subtitle: '50 random questions — official DVSA format',
                          icon: Icons.fact_check_rounded,
                          color: const Color(0xFF3F51B5),
                          onTap: () => startMock(allQuestions, count: 50, label: 'Standard Mock'),
                        ),
                        const SizedBox(height: 12),
                        _MockOptionCard(
                          title: 'Quick Mock',
                          subtitle: '15 random questions — 10 minute warm-up',
                          icon: Icons.bolt_rounded,
                          color: const Color(0xFFFF8C42),
                          onTap: () => startMock(allQuestions, count: 15, label: 'Quick Mock'),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withAlpha(15),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: theme.colorScheme.primary.withAlpha(40)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline_rounded, color: theme.colorScheme.primary, size: 22),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Mock tests use random questions from all categories. You need 86% to pass, matching the real DVSA theory test.',
                                  style: GoogleFonts.outfit(fontSize: 12, height: 1.4),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ]),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;

  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.outfit(fontSize: 10, color: Colors.white.withAlpha(180))),
          Text(value, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
        ],
      ),
    );
  }
}

class _MockOptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String? badge;
  final VoidCallback onTap;

  const _MockOptionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withAlpha(60)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 20 : 8),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withAlpha(25), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 15)),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withAlpha(30),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            badge!,
                            style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w700, color: color),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(fontSize: 12, color: theme.colorScheme.onSurface.withAlpha(140)),
                  ),
                ],
              ),
            ),
            Icon(Icons.play_circle_fill_rounded, color: color, size: 32),
          ],
        ),
      ),
    );
  }
}
