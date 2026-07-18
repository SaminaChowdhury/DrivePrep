import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../models/test_session_log.dart';
import '../providers/progress_provider.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final analytics = ref.watch(progressAnalyticsProvider);

    return Scaffold(
      body: Container(
        color: theme.scaffoldBackgroundColor,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            physics: const BouncingScrollPhysics(),
            children: [
              Text(
                'Learning Analytics',
                style: GoogleFonts.outfit(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'Track your preparedness for the real exam',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withAlpha(140),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      value: '${analytics.totalCompletedTests}',
                      label: 'Tests Completed',
                      icon: Icons.assignment_turned_in_rounded,
                      color: const Color(0xFF3F51B5),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _MetricCard(
                      value: '${(analytics.averageScore * 100).toInt()}%',
                      label: 'Average Score',
                      icon: Icons.trending_up_rounded,
                      color: const Color(0xFF00A896),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _MetricCard(
                value: '${analytics.questionsCorrect} / ${analytics.questionsAnswered}',
                label: 'Theory Questions Correct',
                icon: Icons.checklist_rtl_rounded,
                color: const Color(0xFFE91E63),
                fullWidth: true,
              ),
              const SizedBox(height: 24),
              Text(
                'Topic Performance',
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              _CategoryBarChart(
                topics: analytics.categoryPerformance.take(8).toList(),
                isDark: isDark,
                cardColor: theme.cardTheme.color,
              ),
              const SizedBox(height: 24),
              Text(
                'Weak Topics',
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              if (analytics.weakTopics.isEmpty)
                _EmptyCard(
                  message: 'No weak topics yet. Complete more quizzes to see insights.',
                  cardColor: theme.cardTheme.color,
                )
              else
                ...analytics.weakTopics.map(
                  (topic) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _WeakTopicCard(topic: topic, cardColor: theme.cardTheme.color),
                  ),
                ),
              const SizedBox(height: 24),
              Text(
                'Recent Tests',
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              if (analytics.recentSessions.isEmpty)
                _EmptyCard(
                  message: 'Complete a theory or road signs quiz to log your first test.',
                  cardColor: theme.cardTheme.color,
                )
              else
                ...analytics.recentSessions.map(
                  (session) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _SessionCard(session: session, cardColor: theme.cardTheme.color),
                  ),
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  final bool fullWidth;

  const _MetricCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w900),
          ),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 11,
              color: theme.colorScheme.onSurface.withAlpha(140),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryBarChart extends StatelessWidget {
  final List<TopicPerformance> topics;
  final bool isDark;
  final Color? cardColor;

  const _CategoryBarChart({
    required this.topics,
    required this.isDark,
    required this.cardColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (topics.isEmpty) {
      return _EmptyCard(
        message: 'Answer theory or sign quiz questions to see topic charts.',
        cardColor: cardColor,
      );
    }

    final colors = [
      const Color(0xFF3F51B5),
      const Color(0xFF00A896),
      const Color(0xFFE91E63),
      const Color(0xFFFF8C42),
      const Color(0xFF9C27B0),
      const Color(0xFF0072BC),
      const Color(0xFFFFB300),
      const Color(0xFF607D8B),
    ];

    return Container(
      height: 240,
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.onSurface.withAlpha(15)),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 100,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 25,
            getDrawingHorizontalLine: (value) => FlLine(
              color: theme.colorScheme.onSurface.withAlpha(20),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                interval: 25,
                getTitlesWidget: (value, _) => Text(
                  '${value.toInt()}',
                  style: GoogleFonts.outfit(fontSize: 10, color: theme.colorScheme.onSurface.withAlpha(120)),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= topics.length) return const SizedBox.shrink();
                  final short = topics[index].name.split(' ').first;
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      short.length > 8 ? '${short.substring(0, 7)}…' : short,
                      style: GoogleFonts.outfit(fontSize: 9, color: theme.colorScheme.onSurface.withAlpha(120)),
                    ),
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(topics.length, (index) {
            final rate = topics[index].successRate * 100;
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: rate.clamp(0, 100),
                  color: colors[index % colors.length],
                  width: 16,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _WeakTopicCard extends StatelessWidget {
  final TopicPerformance topic;
  final Color? cardColor;

  const _WeakTopicCard({required this.topic, required this.cardColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFF8C42).withAlpha(60)),
      ),
      child: Row(
        children: [
          CircularPercentIndicator(
            radius: 28,
            lineWidth: 6,
            percent: topic.successRate.clamp(0.0, 1.0),
            center: Text(
              '${(topic.successRate * 100).toInt()}%',
              style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w800),
            ),
            progressColor: const Color(0xFFFF8C42),
            backgroundColor: theme.colorScheme.onSurface.withAlpha(20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(topic.name, style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
                Text(
                  '${topic.attempted} attempted • ${topic.module}',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    color: theme.colorScheme.onSurface.withAlpha(140),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.warning_amber_rounded, color: Color(0xFFFF8C42)),
        ],
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final TestSessionLog session;
  final Color? cardColor;

  const _SessionCard({required this.session, required this.cardColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = session.passed ? const Color(0xFF00A896) : const Color(0xFFD90429);
    final label = session.module == 'theory' ? 'Theory Test' : 'Road Signs Quiz';
    final date = '${session.completedAt.day}/${session.completedAt.month}/${session.completedAt.year}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.onSurface.withAlpha(15)),
      ),
      child: Row(
        children: [
          Icon(
            session.passed ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: statusColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
                Text(
                  '${session.mode}${session.topic != null ? ' • ${session.topic}' : ''} • $date',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    color: theme.colorScheme.onSurface.withAlpha(140),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${session.correct}/${session.total}',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: statusColor),
          ),
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String message;
  final Color? cardColor;

  const _EmptyCard({required this.message, required this.cardColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.onSurface.withAlpha(15)),
      ),
      child: Text(
        message,
        style: GoogleFonts.outfit(
          fontSize: 13,
          color: theme.colorScheme.onSurface.withAlpha(150),
        ),
      ),
    );
  }
}
