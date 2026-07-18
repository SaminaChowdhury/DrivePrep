import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/highway_provider.dart';

class HighwayCodeScreen extends ConsumerStatefulWidget {
  const HighwayCodeScreen({super.key});

  @override
  ConsumerState<HighwayCodeScreen> createState() => _HighwayCodeScreenState();
}

class _HighwayCodeScreenState extends ConsumerState<HighwayCodeScreen> {
  final Set<String> _expandedIds = {};

  static const _sectionColors = {
    'Rules for pedestrians': Color(0xFF3F51B5),
    'Rules for drivers and motorcyclists': Color(0xFF00A896),
    'Using the road': Color(0xFFE91E63),
    'Motorway rules': Color(0xFF9C27B0),
  };

  Color _colorFor(String section) =>
      _sectionColors[section] ?? const Color(0xFFFF8C42);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final entriesAsync = ref.watch(highwayCodeProvider);

    return Scaffold(
      body: entriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Failed to load: $err')),
        data: (entries) {
          final grouped = <String, List<dynamic>>{};
          for (final e in entries) {
            grouped.putIfAbsent(e.section, () => []).add(e);
          }

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [const Color(0xFF4A148C), const Color(0xFF6A1B9A)]
                          : [const Color(0xFF9C27B0), const Color(0xFFE040FB)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 20, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                onPressed: () => context.pop(),
                                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                              ),
                              Expanded(
                                child: Text(
                                  'Highway Code',
                                  style: GoogleFonts.outfit(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: Text(
                              'Official UK road rules & guidance',
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                color: Colors.white.withAlpha(200),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                _HeroStat(value: '${entries.length}', label: 'Rules'),
                                const SizedBox(width: 12),
                                _HeroStat(value: '${grouped.length}', label: 'Sections'),
                                const SizedBox(width: 12),
                                _HeroStat(value: '2026', label: 'Edition'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              ...grouped.entries.expand((group) {
                final color = _colorFor(group.key);
                return [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 22,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              group.key,
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: color,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: color.withAlpha(25),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${group.value.length}',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                color: color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final entry = group.value[index];
                          final isExpanded = _expandedIds.contains(entry.id);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: theme.cardTheme.color,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isExpanded ? color.withAlpha(100) : color.withAlpha(30),
                                  width: isExpanded ? 1.5 : 1,
                                ),
                                boxShadow: isExpanded
                                    ? [BoxShadow(color: color.withAlpha(30), blurRadius: 12, offset: const Offset(0, 4))]
                                    : null,
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () {
                                    setState(() {
                                      if (isExpanded) {
                                        _expandedIds.remove(entry.id);
                                      } else {
                                        _expandedIds.add(entry.id);
                                      }
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 16,
                                              backgroundColor: color.withAlpha(30),
                                              child: Text(
                                                '${entry.order}',
                                                style: GoogleFonts.outfit(
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 12,
                                                  color: color,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                entry.title,
                                                style: GoogleFonts.outfit(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ),
                                            Icon(
                                              isExpanded
                                                  ? Icons.keyboard_arrow_up_rounded
                                                  : Icons.keyboard_arrow_down_rounded,
                                              color: color,
                                            ),
                                          ],
                                        ),
                                        if (isExpanded) ...[
                                          const SizedBox(height: 12),
                                          Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.all(14),
                                            decoration: BoxDecoration(
                                              color: color.withAlpha(15),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              entry.content,
                                              style: GoogleFonts.outfit(
                                                fontSize: 14,
                                                height: 1.55,
                                                color: theme.colorScheme.onSurface.withAlpha(200),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        childCount: group.value.length,
                      ),
                    ),
                  ),
                ];
              }),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          );
        },
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String value;
  final String label;

  const _HeroStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(30),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.outfit(fontSize: 11, color: Colors.white.withAlpha(200)),
            ),
          ],
        ),
      ),
    );
  }
}
