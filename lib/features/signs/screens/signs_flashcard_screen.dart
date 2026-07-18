import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/road_sign.dart';
import '../providers/signs_provider.dart';
import '../widgets/sign_image_card.dart';

class SignsFlashcardScreen extends ConsumerStatefulWidget {
  const SignsFlashcardScreen({super.key});

  @override
  ConsumerState<SignsFlashcardScreen> createState() => _SignsFlashcardScreenState();
}

class _SignsFlashcardScreenState extends ConsumerState<SignsFlashcardScreen> {
  late int _currentIndex;
  bool _showMeaning = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = ref.read(signFlashcardSessionProvider)?.initialIndex ?? 0;
  }

  void _flipCard() {
    setState(() => _showMeaning = !_showMeaning);
  }

  void _goToIndex(int index) {
    setState(() {
      _currentIndex = index;
      _showMeaning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(signFlashcardSessionProvider);
    final theme = Theme.of(context);

    if (session == null || session.signs.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Flashcards')),
        body: Center(
          child: ElevatedButton(
            onPressed: () => context.go('/signs'),
            child: const Text('Back to dashboard'),
          ),
        ),
      );
    }

    final signs = session.signs;
    final sign = signs[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Flashcards',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w800),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${_currentIndex + 1}/${signs.length}',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (_currentIndex + 1) / signs.length,
              minHeight: 6,
              borderRadius: BorderRadius.circular(6),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GestureDetector(
                onTap: _flipCard,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _showMeaning
                      ? _MeaningSide(sign: sign, key: const ValueKey('meaning'))
                      : _ImageSide(sign: sign, key: const ValueKey('image')),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _showMeaning ? 'Tap to see sign' : 'Tap card to reveal meaning',
              style: GoogleFonts.outfit(
                fontSize: 13,
                color: theme.colorScheme.onSurface.withAlpha(150),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _currentIndex > 0
                        ? () => _goToIndex(_currentIndex - 1)
                        : null,
                    icon: const Icon(Icons.chevron_left_rounded),
                    label: const Text('Previous'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _currentIndex < signs.length - 1
                        ? () => _goToIndex(_currentIndex + 1)
                        : () => context.pop(),
                    icon: Icon(
                      _currentIndex < signs.length - 1
                          ? Icons.chevron_right_rounded
                          : Icons.check_rounded,
                    ),
                    label: Text(
                      _currentIndex < signs.length - 1 ? 'Next' : 'Done',
                    ),
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

class _ImageSide extends StatelessWidget {
  final RoadSign sign;

  const _ImageSide({super.key, required this.sign});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.primary.withAlpha(40)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SignImageCard(sign: sign, height: 200),
          const SizedBox(height: 24),
          Text(
            'What does this sign mean?',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MeaningSide extends StatelessWidget {
  final RoadSign sign;

  const _MeaningSide({super.key, required this.sign});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withAlpha(20),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.primary.withAlpha(60)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withAlpha(30),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              sign.category,
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.primary,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            sign.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            sign.meaning,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 15,
              height: 1.5,
              color: theme.colorScheme.onSurface.withAlpha(200),
            ),
          ),
        ],
      ),
    );
  }
}
