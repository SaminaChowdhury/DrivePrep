import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/hive_service.dart';

// Simple theme provider to toggle theme modes and persist in Hive
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return ThemeModeNotifier(hiveService);
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final HiveService _hiveService;

  ThemeModeNotifier(this._hiveService)
      : super(_hiveService.isDarkMode() ? ThemeMode.dark : ThemeMode.light);

  void toggleTheme() async {
    if (state == ThemeMode.light) {
      state = ThemeMode.dark;
      await _hiveService.setDarkMode(true);
    } else {
      state = ThemeMode.light;
      await _hiveService.setDarkMode(false);
    }
  }
}

class DashboardScreen extends ConsumerWidget {
  final Widget navigationShell;

  const DashboardScreen({
    super.key,
    required this.navigationShell,
  });

  // Match current routes to simplified 3-tab layout indices
  int _getCurrentIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/progress')) return 1;
    if (location.startsWith('/settings')) return 2;
    return 0; // default is /home (including any sub-theory/hazard/etc. paths)
  }

  void _onTabTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/progress');
        break;
      case 2:
        context.go('/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final currentIndex = _getCurrentIndex(context);

    // Dynamic label helper to set header titles
    String getAppBarTitle(int index) {
      switch (index) {
        case 0:
          return 'DrivePrep';
        case 1:
          return 'Analytics';
        case 2:
          return 'Settings';
        default:
          return 'DrivePrep';
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.directions_car_rounded,
              color: theme.colorScheme.primary,
              size: 26,
            ),
            const SizedBox(width: 8),
            Text(
              getAppBarTitle(currentIndex),
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, anim) => RotationTransition(
                turns: anim,
                child: FadeTransition(opacity: anim, child: child),
              ),
              child: themeMode == ThemeMode.dark
                  ? const Icon(Icons.wb_sunny_rounded, key: ValueKey('light_icon'), color: Colors.amber)
                  : const Icon(Icons.nightlight_round_rounded, key: ValueKey('dark_icon'), color: Colors.indigo),
            ),
            onPressed: () {
              ref.read(themeModeProvider.notifier).toggleTheme();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: navigationShell,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(theme.brightness == Brightness.dark ? 40 : 15),
              blurRadius: 15,
              offset: const Offset(0, -4),
            )
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) => _onTabTapped(context, index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart_rounded),
              label: 'Analytics',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings_rounded),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
