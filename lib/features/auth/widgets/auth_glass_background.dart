import 'dart:ui';

import 'package:flutter/material.dart';

/// Soft glassmorphism backdrop for auth screens.
class AuthGlassBackground extends StatelessWidget {
  final Widget child;

  const AuthGlassBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF0B1220),
                Color(0xFF0F4C81),
                Color(0xFF1D5A96),
                Color(0xFF2E7D9A),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        Positioned(
          top: -80,
          right: -60,
          child: _GlowOrb(color: const Color(0xFF00E5FF).withAlpha(60), size: 220),
        ),
        Positioned(
          bottom: 100,
          left: -70,
          child: _GlowOrb(color: const Color(0xFF9C27B0).withAlpha(50), size: 180),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.35,
          right: 40,
          child: _GlowOrb(color: const Color(0xFFFF8C42).withAlpha(40), size: 120),
        ),
        child,
      ],
    );
  }
}

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
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(28),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withAlpha(45), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(50),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final Color color;
  final double size;

  const _GlowOrb({required this.color, required this.size});

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
