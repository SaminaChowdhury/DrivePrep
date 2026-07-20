import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../../auth/providers/auth_provider.dart';

// Profile from Firebase Auth when signed in (verified users only).
final userProfileProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final authState = ref.watch(authProvider);
  if (authState != AuthState.authenticated) return null;

  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return null;

  return {
    'email': user.email,
    'username': user.displayName ?? user.email?.split('@').first,
    'full_name': user.displayName,
  };
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _HomeScreenContent();
  }
}

class _HomeScreenContent extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authState = ref.watch(authProvider);
    final profileAsync = ref.watch(userProfileProvider);

    // Get dynamic username based on AuthState
    String getGreetingName() {
      if (authState == AuthState.guest) {
        return 'Guest Driver';
      }
      return profileAsync.maybeWhen(
        data: (data) => data?['full_name'] ?? data?['username'] ?? 'Learner',
        orElse: () => 'Learner',
      );
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: theme.scaffoldBackgroundColor,
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1. Beautiful Dynamic Header Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello,',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: theme.colorScheme.onSurface.withAlpha(160),
                            ),
                          ),
                          Text(
                            getGreetingName(),
                            style: GoogleFonts.outfit(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      // Elegant Profile Avatar / Mode Tag
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: authState == AuthState.guest
                              ? Colors.amber.withAlpha(25)
                              : theme.colorScheme.primary.withAlpha(25),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: authState == AuthState.guest
                                ? Colors.amber.withAlpha(100)
                                : theme.colorScheme.primary.withAlpha(100),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              authState == AuthState.guest
                                  ? Icons.emoji_people_rounded
                                  : Icons.verified_user_rounded,
                              size: 16,
                              color: authState == AuthState.guest
                                  ? Colors.amber[800] ?? Colors.amber
                                  : theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              authState == AuthState.guest ? 'Guest' : 'Premium',
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: authState == AuthState.guest
                                    ? Colors.amber[800] ?? Colors.amber
                                    : theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. High-Fidelity Progress Ring Card (WOW factor)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                        // Progress ring
                        CircularPercentIndicator(
                          radius: 45.0,
                          lineWidth: 9.0,
                          percent: 0.65,
                          center: Text(
                            "65%",
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                          circularStrokeCap: CircularStrokeCap.round,
                          backgroundColor: Colors.white.withAlpha(40),
                          progressColor: const Color(0xFF00E5FF),
                        ),
                        const SizedBox(width: 20),
                        // Progress Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Overall Pass Probability',
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withAlpha(200),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Highly Prepared',
                                style: GoogleFonts.outfit(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Practice 120 more questions to reach 90% target probability.',
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
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

              // 3. Grid of Main Learning Features
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.95,
                  ),
                  delegate: SliverChildListDelegate([
                    // Card 1: Theory Test
                    _buildFeatureCard(
                      context: context,
                      title: 'Theory Test',
                      subtitle: '14 revision topics',
                      icon: Icons.assignment_rounded,
                      color: const Color(0xFF3F51B5), // Indigo
                      onTap: () => context.push('/theory'),
                    ),
                    // Card 2: Mock Test
                    _buildFeatureCard(
                      context: context,
                      title: 'Mock Test',
                      subtitle: 'Real DVSA simulation',
                      icon: Icons.assignment_turned_in_rounded,
                      color: const Color(0xFF00A896), // Emerald/Teal
                      onTap: () => context.push('/mock-test'),
                    ),
                    // Card 3: Hazard Perception
                    _buildFeatureCard(
                      context: context,
                      title: 'Hazard Perception',
                      subtitle: 'Interactive CGI clips',
                      icon: Icons.visibility_rounded,
                      color: const Color(0xFFFF8C42), // Orange
                      onTap: () => context.push('/hazard'),
                    ),
                    // Card 4: Highway Code
                    _buildFeatureCard(
                      context: context,
                      title: 'Highway Code',
                      subtitle: 'Full 2026 guidelines',
                      icon: Icons.menu_book_rounded,
                      color: const Color(0xFF9C27B0), // Purple
                      onTap: () => context.push('/highway'),
                    ),
                    // Card 5: Road Signs
                    _buildFeatureCard(
                      context: context,
                      title: 'Road Signs',
                      subtitle: 'Flashcards & games',
                      icon: Icons.traffic_rounded,
                      color: const Color(0xFFE91E63), // Pink/Crimson
                      onTap: () => context.push('/signs'),
                    ),

                  ]),
                ),
              ),

              // 4. Quick Mini-Tip Banner at bottom
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.colorScheme.onSurface.withAlpha(isDark ? 15 : 10),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.lightbulb_outline_rounded,
                          color: Colors.amber,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Tip: Did you know? 1 in 3 learners fail due to Hazard Perception. Practice daily!',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: theme.colorScheme.onSurface.withAlpha(180),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }

  // Premium Feature Card Builder
  Widget _buildFeatureCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isDark ? Colors.white.withAlpha(15) : Colors.black.withAlpha(10),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 30 : 10),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Colored Circular Icon Container
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 26,
                color: color,
              ),
            ),
            // Text Details
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: theme.colorScheme.onSurface.withAlpha(140),
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
