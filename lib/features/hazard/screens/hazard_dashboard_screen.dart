import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/hazard_video.dart';
import '../providers/hazard_provider.dart';
import 'hazard_practice_screen.dart';

class HazardDashboardScreen extends ConsumerWidget {
  const HazardDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final videosAsync = ref.watch(hazardVideosProvider);

    return Scaffold(
      body: Container(
        color: theme.scaffoldBackgroundColor,
        child: SafeArea(
          child: videosAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Failed to load: $err')),
            data: (videos) => CustomScrollView(
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
                          'Hazard Perception',
                          style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w800),
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
                              ? [const Color(0xFFBF360C), const Color(0xFFE65100)]
                              : [const Color(0xFFFF8C42), const Color(0xFFFFB74D)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.visibility_rounded, color: Colors.white, size: 32),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  'Spot the developing hazard',
                                  style: GoogleFonts.outfit(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Tap as soon as you see a hazard developing. Earlier taps score higher — up to 5 points per clip.',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              height: 1.45,
                              color: Colors.white.withAlpha(220),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 10,
                            runSpacing: 8,
                            children: [
                              _InfoPill(icon: Icons.movie_rounded, label: '${videos.length} clips'),
                              _InfoPill(icon: Icons.timer_rounded, label: '15 sec each'),
                              _InfoPill(icon: Icons.star_rounded, label: 'Pass: 44/75'),
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
                      'How it works',
                      style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        _StepCard(step: '1', title: 'Watch', subtitle: 'Study the road scene', color: const Color(0xFF3F51B5)),
                        const SizedBox(width: 10),
                        _StepCard(step: '2', title: 'Tap', subtitle: 'When hazard develops', color: const Color(0xFFFF8C42)),
                        const SizedBox(width: 10),
                        _StepCard(step: '3', title: 'Score', subtitle: 'Earlier = more points', color: const Color(0xFF00A896)),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                    child: Text(
                      'Practice Clips',
                      style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final video = videos[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _ClipCard(
                            video: video,
                            index: index + 1,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => HazardPracticeScreen(video: video),
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: videos.length,
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
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(30),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(label, style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final String step;
  final String title;
  final String subtitle;
  final Color color;

  const _StepCard({
    required this.step,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withAlpha(50)),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: color,
              child: Text(step, style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 12)),
            ),
            const SizedBox(height: 8),
            Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 12)),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(fontSize: 9, color: Theme.of(context).colorScheme.onSurface.withAlpha(140)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClipCard extends StatelessWidget {
  final HazardVideo video;
  final int index;
  final VoidCallback onTap;

  const _ClipCard({required this.video, required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = {
      'Urban': const Color(0xFF3F51B5),
      'Junctions': const Color(0xFFE91E63),
      'Motorway': const Color(0xFF00A896),
    };
    final color = colors[video.category] ?? const Color(0xFFFF8C42);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withAlpha(50)),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [color, color.withAlpha(180)]),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  '$index',
                  style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withAlpha(25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          video.category,
                          style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w700, color: color),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${video.durationSeconds}s',
                        style: GoogleFonts.outfit(fontSize: 11, color: theme.colorScheme.onSurface.withAlpha(120)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(video.title, style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 15)),
                  Text(
                    video.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(fontSize: 12, color: theme.colorScheme.onSurface.withAlpha(140)),
                  ),
                ],
              ),
            ),
            Icon(Icons.play_circle_fill_rounded, color: color, size: 36),
          ],
        ),
      ),
    );
  }
}
