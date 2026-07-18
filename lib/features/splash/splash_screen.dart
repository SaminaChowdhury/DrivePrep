import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/hive_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/offline_sync_service.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  double _loadingProgress = 0.0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
    _startInitialization();
  }

  void _startInitialization() async {
    // Simulate gradual initialization steps to show progress on splash screen
    for (int i = 1; i <= 6; i++) {
      await Future.delayed(const Duration(milliseconds: 120));
      if (mounted) {
        setState(() {
          _loadingProgress = i / 10.0;
        });
      }
    }

    // Initialize Hive and sync offline content (Hive → API → bundled defaults)
    final hiveService = ref.read(hiveServiceProvider);
    await hiveService.init();

    final syncService = ref.read(offlineSyncServiceProvider);
    await syncService.syncAll();

    if (mounted) {
      setState(() {
        _loadingProgress = 0.8;
      });
    }

    // Check secure storage authentication status
    final authService = ref.read(authServiceProvider);
    final isLoggedIn = await authService.isLoggedIn();
    final isGuest = await authService.isGuest();

    for (int i = 9; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        setState(() {
          _loadingProgress = i / 10.0;
        });
      }
    }

    if (mounted) {
      if (isLoggedIn || isGuest) {
        context.go('/home');
      } else {
        context.go('/login');
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0B1220), // Extremely Deep Blue-Black
              Color(0xFF0F4C81), // Classic Navy
              Color(0xFF1D5A96), // Royal Indigo
            ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Floating background accent shapes
            Positioned(
              top: -size.height * 0.1,
              right: -size.width * 0.2,
              child: Container(
                width: size.width * 0.7,
                height: size.width * 0.7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.cyan.withAlpha(20),
                ),
              ),
            ),
            Positioned(
              bottom: -size.height * 0.15,
              left: -size.width * 0.1,
              child: Container(
                width: size.width * 0.8,
                height: size.width * 0.8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue.withAlpha(15),
                ),
              ),
            ),

            // Center Branding Details
            FadeTransition(
              opacity: _opacityAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Brand Icon
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(25),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withAlpha(40), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.cyan.withAlpha(50),
                            blurRadius: 30,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                      child: const Icon(
                        Icons.directions_car_rounded,
                        size: 72,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Main Title
                    const Text(
                      'DrivePrep',
                      style: TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Subtitle
                    Text(
                      'UK Driving Theory 4-in-1 Suite',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withAlpha(180),
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: size.height * 0.12),
                    // Progress Indicator Container
                    SizedBox(
                      width: size.width * 0.65,
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: _loadingProgress,
                              minHeight: 5,
                              backgroundColor: Colors.white.withAlpha(30),
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Loading local database... ${( _loadingProgress * 100).toInt()}%',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withAlpha(150),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Version Text
            Positioned(
              bottom: 40,
              child: Text(
                'v1.0.0 • Offline Ready',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withAlpha(100),
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
