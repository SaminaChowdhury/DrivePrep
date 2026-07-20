import 'dart:ui';

import 'package:flutter/material.dart';

/// Auth glass tokens aligned with [AppTheme] (Classic Navy + teal/cyan).
class AuthColors {
  /// Classic Navy — primary buttons / deep accents
  static const midnightNavy = Color(0xFF0F4C81);

  /// Dark slate surface
  static const charcoalGrey = Color(0xFF1E293B);

  /// Frosted glass fill (white glass over navy)
  static const warmIvory = Color.fromRGBO(255, 255, 255, 0.10);

  /// Teal border glow (secondary)
  static const roseGold = Color.fromRGBO(0, 168, 150, 0.35);

  /// Cyan accent (matches home progress / splash highlights)
  static const roseGoldSolid = Color(0xFF00E5FF);

  /// Ice white text (dark theme primary)
  static const alabaster = Color(0xFFF8FAFC);

  /// Semi-transparent input fill
  static const inputFill = Color.fromRGBO(255, 255, 255, 0.06);

  // Lighter, more saturated navy → blue sweep for the background.
  static const deepSlate = Color(0xFF16345C);
  static const classicNavy = Color(0xFF1E6FB8);
  static const royalIndigo = Color(0xFF2E8FC4);
}

/// App-themed lighter navy gradient + frosted glass background.
class AuthGlassBackground extends StatelessWidget {
  final Widget child;

  const AuthGlassBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AuthColors.deepSlate,
                AuthColors.classicNavy,
                AuthColors.royalIndigo,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        Positioned(
          top: -size.height * 0.08,
          right: -size.width * 0.15,
          child: _GlowBlob(
            size: size.width * 0.7,
            color: const Color(0xFF00E5FF).withAlpha(18),
          ),
        ),
        Positioned(
          bottom: -size.height * 0.12,
          left: -size.width * 0.2,
          child: _GlowBlob(
            size: size.width * 0.8,
            color: const Color(0xFF00A896).withAlpha(22),
          ),
        ),
        child,
      ],
    );
  }
}

/// Frosted glass card with teal/cyan glow (original simple structure).
class AuthGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const AuthGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: -40,
          child: IgnorePointer(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 36, sigmaY: 36),
              child: Container(
                width: 220,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AuthColors.roseGoldSolid.withAlpha(80),
                      const Color(0xFF00A896).withAlpha(40),
                      AuthColors.roseGoldSolid.withAlpha(0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              width: double.infinity,
              padding: padding,
              decoration: BoxDecoration(
                color: AuthColors.warmIvory,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AuthColors.roseGold,
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AuthColors.roseGoldSolid.withAlpha(35),
                    blurRadius: 32,
                    spreadRadius: 2,
                    offset: const Offset(0, 12),
                  ),
                  BoxShadow(
                    color: Colors.black.withAlpha(70),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}

class _GlowBlob extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowBlob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withAlpha(0)]),
      ),
    );
  }
}