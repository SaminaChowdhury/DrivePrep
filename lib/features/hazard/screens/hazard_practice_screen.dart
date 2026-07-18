import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

import '../models/hazard_video.dart';

class HazardPracticeScreen extends StatefulWidget {
  final HazardVideo video;

  const HazardPracticeScreen({super.key, required this.video});

  @override
  State<HazardPracticeScreen> createState() => _HazardPracticeScreenState();
}

class _HazardPracticeScreenState extends State<HazardPracticeScreen> {
  VideoPlayerController? _controller;
  bool _loading = true;
  bool _hasError = false;
  bool _tapped = false;
  int? _score;
  String? _feedback;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    try {
      final controller = VideoPlayerController.networkUrl(Uri.parse(widget.video.videoUrl));
      await controller.initialize();
      controller.setLooping(true);
      if (mounted) {
        setState(() {
          _controller = controller;
          _loading = false;
        });
        controller.play();
      }
    } catch (_) {
      if (mounted) setState(() { _loading = false; _hasError = true; });
    }
  }

  void _onHazardTap() {
    if (_tapped || _controller == null || !_controller!.value.isInitialized) return;
    final position = _controller!.value.position.inSeconds;
    final hazardAt = widget.video.hazardTimestampSeconds;
    final diff = (position - hazardAt).abs();

    int score;
    String feedback;
    if (position < hazardAt - 3) {
      score = 1;
      feedback = 'Too early — wait until the hazard actually develops.';
    } else if (diff <= 1) {
      score = 5;
      feedback = 'Excellent timing! Maximum points.';
    } else if (diff <= 3) {
      score = 3;
      feedback = 'Good spot — a little late but solid.';
    } else {
      score = 1;
      feedback = 'Too late — the hazard was already developing.';
    }

    setState(() {
      _tapped = true;
      _score = score;
      _feedback = feedback;
    });
    _controller!.pause();
  }

  void _retry() {
    setState(() {
      _tapped = false;
      _score = null;
      _feedback = null;
    });
    _controller?.seekTo(Duration.zero);
    _controller?.play();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.video.title, style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _onHazardTap,
              child: Center(
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : _hasError
                        ? Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.wifi_off_rounded, color: Colors.white54, size: 48),
                                const SizedBox(height: 12),
                                Text(
                                  'Clip unavailable offline.\nConnect to the internet to stream this clip.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.outfit(color: Colors.white70),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  widget.video.description,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.outfit(color: Colors.white54, fontSize: 13),
                                ),
                              ],
                            ),
                          )
                        : AspectRatio(
                            aspectRatio: _controller!.value.aspectRatio,
                            child: VideoPlayer(_controller!),
                          ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: const Color(0xFF1A1A2E),
            child: Column(
              children: [
                if (!_tapped) ...[
                  Text(
                    'Tap anywhere when you see the hazard developing',
                    style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.video.description,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12),
                  ),
                ] else ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      return Icon(
                        i < (_score ?? 0) ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: const Color(0xFFFFB300),
                        size: 28,
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$_score / 5 points',
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(_feedback!, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton(
                        onPressed: _retry,
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.white),
                        child: const Text('Try Again'),
                      ),
                      const SizedBox(width: 12),
                      FilledButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Back to Clips'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
