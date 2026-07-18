import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/road_sign.dart';

class SignImageCard extends StatelessWidget {
  final RoadSign sign;
  final double height;

  const SignImageCard({
    super.key,
    required this.sign,
    this.height = 160,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: height,
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.onSurface.withAlpha(20),
        ),
      ),
      child: SvgPicture.asset(
        sign.imageAssetPath,
        fit: BoxFit.contain,
        placeholderBuilder: (_) => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
