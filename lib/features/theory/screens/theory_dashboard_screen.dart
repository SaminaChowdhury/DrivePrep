import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../providers/theory_provider.dart';
import '../models/theory_question.dart';

class TheoryDashboardScreen extends ConsumerWidget {
  const TheoryDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Watch providers
    final questionsAsync = ref.watch(theoryQuestionsProvider);
    final bookmarks = ref.watch(bookmarksProvider);
    final progressMap = ref.watch(categoryProgressProvider);

    // Categories mapping to icons and colors
    final Map<String, _CategoryUiConfig> categoryConfigs = {
      'Alertness': _CategoryUiConfig(Icons.lightbulb_rounded, const Color(0xFF3F51B5)),
      'Attitude': _CategoryUiConfig(Icons.sentiment_satisfied_alt_rounded, const Color(0xFF00A896)),
      'Safety and Your Vehicle': _CategoryUiConfig(Icons.build_rounded, const Color(0xFF2196F3)),
      'Safety Margins': _CategoryUiConfig(Icons.space_bar_rounded, const Color(0xFF00BCD4)),
      'Hazard Awareness': _CategoryUiConfig(Icons.warning_amber_rounded, const Color(0xFFFFB300)),
      'Vulnerable Road Users': _CategoryUiConfig(Icons.directions_bike_rounded, const Color(0xFFFF9800)),
      'Other Types of Vehicle': _CategoryUiConfig(Icons.airport_shuttle_rounded, const Color(0xFFFF5722)),
      'Vehicle Handling': _CategoryUiConfig(Icons.sports_motorsports_rounded, const Color(0xFF9C27B0)),
      'Motorway Rules': _CategoryUiConfig(Icons.add_road_rounded, const Color(0xFF1E88E5)),
      'Rules of the Road': _CategoryUiConfig(Icons.alt_route_rounded, const Color(0xFF4CAF50)),
      'Road and Traffic Signs': _CategoryUiConfig(Icons.traffic_rounded, const Color(0xFFE91E63)),
      'Essential Documents': _CategoryUiConfig(Icons.description_rounded, const Color(0xFF607D8B)),
      'Incidents, Accidents and Emergencies': _CategoryUiConfig(Icons.local_hospital_rounded, const Color(0xFFE53935)),
      'Pedestrian Crossings': _CategoryUiConfig(Icons.directions_walk_rounded, const Color(0xFF673AB7)),
    };

    // Helper to launch quiz
    void startQuizSession(List<TheoryQuestion> questions, String mode, {String? category}) {
      ref.read(theoryQuizProvider.notifier).startQuiz(questions, mode, category: category);
      context.push('/theory-quiz');
    }

    return Scaffold(
      body: Container(
        color: theme.scaffoldBackgroundColor,
        child: SafeArea(
          child: questionsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(
              child: Text(
                'Failed to load questions: $err',
                style: GoogleFonts.outfit(color: theme.colorScheme.error),
              ),
            ),
            data: (allQuestions) {
              // Calculate overall completion stats
              final totalQCount = allQuestions.length;
              int completedQCount = 0;
              int correctQCount = 0;

              progressMap.forEach((_, progress) {
                completedQCount += progress.completedQuestions;
                correctQCount += progress.correctQuestions;
              });

              final overallPercent = totalQCount == 0 ? 0.0 : completedQCount / totalQCount;
              final overallSuccess = completedQCount == 0 ? 0.0 : correctQCount / completedQCount;

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // 1. Beautiful Dashboard Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new_rounded),
                            onPressed: () => context.go('/home'),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Theory Suite',
                            style: GoogleFonts.outfit(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 2. High-Fidelity Overall Progress Ring Card
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark
                                ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                                : [const Color(0xFF0F4C81), const Color(0xFF1D5A96)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withAlpha(isDark ? 30 : 50),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            )
                          ],
                        ),
                        child: Row(
                          children: [
                            CircularPercentIndicator(
                              radius: 40.0,
                              lineWidth: 8.0,
                              percent: overallPercent,
                              center: Text(
                                "${(overallPercent * 100).toInt()}%",
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                              circularStrokeCap: CircularStrokeCap.round,
                              backgroundColor: Colors.white.withAlpha(40),
                              progressColor: const Color(0xFF00E5FF),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Overall Practice Progress',
                                    style: GoogleFonts.outfit(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white.withAlpha(200),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$completedQCount / $totalQCount Questions Done',
                                    style: GoogleFonts.outfit(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    completedQCount == 0
                                        ? 'Tap any category below to start practicing.'
                                        : 'Success rate: ${(overallSuccess * 100).toInt()}% correct answers.',
                                    style: GoogleFonts.outfit(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white.withAlpha(160),
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

                  // 3. Quick Action: Bookmarks only
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: InkWell(
                        onTap: () {
                          if (bookmarks.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('You haven\'t bookmarked any questions yet!'),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            );
                            return;
                          }
                          final bookmarkedQs = allQuestions.where((q) => bookmarks.contains(q.id)).toList();
                          startQuizSession(bookmarkedQs, 'bookmarks');
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.tertiary.withAlpha(20),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: theme.colorScheme.tertiary.withAlpha(100),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.bookmark_rounded, color: theme.colorScheme.tertiary, size: 28),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Bookmarked Questions',
                                      style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 15),
                                    ),
                                    Text(
                                      '${bookmarks.length} saved questions',
                                      style: GoogleFonts.outfit(
                                        fontSize: 12,
                                        color: theme.colorScheme.onSurface.withAlpha(140),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.chevron_right_rounded, color: theme.colorScheme.tertiary),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 4. Section Label: Categories
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
                      child: Text(
                        'Practice by Category',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),

                  // 5. Grid list of Categories
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final categoryName = categoryConfigs.keys.elementAt(index);
                          final config = categoryConfigs[categoryName]!;
                          final progress = progressMap[categoryName] ?? CategoryProgress(
                            category: categoryName,
                            totalQuestions: 0,
                            completedQuestions: 0,
                            correctQuestions: 0,
                          );

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildCategoryCard(
                              context: context,
                              title: categoryName,
                              progress: progress,
                              icon: config.icon,
                              color: config.color,
                              onTap: () {
                                final questions = allQuestions.where((q) => q.category == categoryName).toList();
                                if (questions.isEmpty) return;
                                startQuizSession(questions, 'category', category: categoryName);
                              },
                            ),
                          );
                        },
                        childCount: categoryConfigs.length,
                      ),
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

  // Beautiful Category Card Layout
  Widget _buildCategoryCard({
    required BuildContext context,
    required String title,
    required CategoryProgress progress,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final percent = progress.completionRate;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? Colors.white.withAlpha(15) : Colors.black.withAlpha(10),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 15 : 5),
              blurRadius: 8,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Row(
          children: [
            // Category custom colored icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 24,
                color: color,
              ),
            ),
            const SizedBox(width: 16),

            // Middle section (Text and progress bar)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${progress.completedQuestions} of ${progress.totalQuestions} completed',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      color: theme.colorScheme.onSurface.withAlpha(120),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Progress indicator
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: percent,
                      minHeight: 5,
                      backgroundColor: color.withAlpha(20),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // Right Chevron / completion percent tag
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${(percent * 100).toInt()}%',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: percent == 1.0 ? Colors.green : color,
                  ),
                ),
                const SizedBox(height: 4),
                Icon(
                  percent == 1.0 ? Icons.check_circle_rounded : Icons.chevron_right_rounded,
                  color: percent == 1.0 ? Colors.green : theme.colorScheme.onSurface.withAlpha(80),
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryUiConfig {
  final IconData icon;
  final Color color;
  _CategoryUiConfig(this.icon, this.color);
}
