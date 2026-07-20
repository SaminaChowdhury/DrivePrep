import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/splash/splash_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/progress/screens/progress_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/verify_email_screen.dart';
import '../../features/hazard/screens/hazard_dashboard_screen.dart';
import '../../features/theory/screens/mock_test_screen.dart';
import '../../features/theory/screens/theory_dashboard_screen.dart';
import '../../features/theory/screens/theory_quiz_screen.dart';
import '../../features/theory/screens/theory_results_screen.dart';
import '../../features/signs/screens/signs_dashboard_screen.dart';
import '../../features/signs/screens/signs_flashcard_screen.dart';
import '../../features/signs/screens/signs_quiz_screen.dart';
import '../../features/signs/screens/signs_quiz_results_screen.dart';
import '../../features/highway/screens/highway_code_screen.dart';
final GlobalKey<NavigatorState> rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _rootNavigatorKey = rootNavigatorKey;
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    routes: [
      // 1. Splash Screen
      GoRoute(
        path: '/splash',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SplashScreen(),
      ),

      // 2. Authentication Screens
      GoRoute(
        path: '/login',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/verify-email',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final email = state.extra is String ? state.extra as String : null;
          return VerifyEmailScreen(email: email);
        },
      ),

      // 3. Detail Feature Screens
      GoRoute(
        path: '/mock-test',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const MockTestScreen(),
      ),
      GoRoute(
        path: '/theory',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const TheoryDashboardScreen(),
      ),
      GoRoute(
        path: '/theory-quiz',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const TheoryQuizScreen(),
      ),
      GoRoute(
        path: '/theory-results',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const TheoryResultsScreen(),
      ),
      GoRoute(
        path: '/hazard',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const HazardDashboardScreen(),
      ),
      GoRoute(
        path: '/highway',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const HighwayCodeScreen(),
      ),
      GoRoute(
        path: '/signs',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SignsDashboardScreen(),
      ),
      GoRoute(
        path: '/signs-flashcards',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SignsFlashcardScreen(),
      ),
      GoRoute(
        path: '/signs-quiz',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SignsQuizScreen(),
      ),
      GoRoute(
        path: '/signs-results',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SignsQuizResultsScreen(),
      ),

      // 4. Shell Navigation for Bottom Navigation Tabs
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return DashboardScreen(navigationShell: child);
        },
        routes: [
          // Tab 1: Dashboard Home Screen
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          // Tab 2: Progress Analytics Screen
          GoRoute(
            path: '/progress',
            builder: (context, state) => const ProgressScreen(),
          ),
          // Tab 3: settings Screen
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
});
