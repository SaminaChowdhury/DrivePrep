import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../auth/providers/auth_provider.dart';
import '../../home/screens/home_screen.dart';
import '../../dashboard/dashboard_screen.dart';
import '../../../core/services/hive_service.dart';
import '../../../core/services/offline_sync_service.dart';
import '../../../core/providers/notification_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authState = ref.watch(authProvider);
    final profileAsync = ref.watch(userProfileProvider);
    final hiveService = ref.watch(hiveServiceProvider);
    final lastSync = hiveService.getLastSyncAt();
    final offlineReady = hiveService.isQuestionsSeeded() &&
        hiveService.isRoadSignsSeeded() &&
        hiveService.isHighwayCodeSeeded();
    final notificationSettings = ref.watch(notificationSettingsProvider);

    // Profile detail helpers
    String getUserName() => profileAsync.maybeWhen(
          data: (data) => data?['username'] ?? 'Guest User',
          orElse: () => 'Guest User',
        );

    String getUserEmail() => profileAsync.maybeWhen(
          data: (data) => data?['email'] ?? 'Not logged in',
          orElse: () => 'Not logged in',
        );

    return Scaffold(
      body: Container(
        color: theme.scaffoldBackgroundColor,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            physics: const BouncingScrollPhysics(),
            children: [
              // 1. Account Details Header card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? Colors.white.withAlpha(15) : Colors.black.withAlpha(10),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(isDark ? 30 : 10),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: theme.colorScheme.primary.withAlpha(20),
                      child: Icon(
                        Icons.person_rounded,
                        size: 32,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            authState == AuthState.guest
                                ? 'Guest Mode'
                                : profileAsync.maybeWhen(
                                    data: (data) => data?['full_name'] ?? getUserName(),
                                    orElse: () => getUserName(),
                                  ),
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            authState == AuthState.guest ? 'guest@driveprep.local' : getUserEmail(),
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              color: theme.colorScheme.onSurface.withAlpha(140),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 2. Settings Group: Customization
              _buildSectionTitle(context, 'App Customization'),
              const SizedBox(height: 8),
              _buildSettingsCard(
                context: context,
                children: [
                  // Dark Mode Switcher
                  ListTile(
                    leading: Icon(Icons.dark_mode_outlined, color: theme.colorScheme.primary),
                    title: Text(
                      'Dark Theme',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                    subtitle: Text(
                      'Optimize interface for night review',
                      style: GoogleFonts.outfit(fontSize: 12),
                    ),
                    trailing: Switch(
                      value: ref.watch(themeModeProvider) == ThemeMode.dark,
                      onChanged: (val) {
                        ref.read(themeModeProvider.notifier).toggleTheme();
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Notifications
              _buildSectionTitle(context, 'Reminders'),
              const SizedBox(height: 8),
              _buildSettingsCard(
                context: context,
                children: [
                  ListTile(
                    leading: Icon(Icons.notifications_active_outlined, color: theme.colorScheme.primary),
                    title: Text(
                      'Daily study reminder',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                    subtitle: Text(
                      notificationSettings.dailyReminderEnabled
                          ? 'Every day at ${notificationSettings.dailyReminderLabel}'
                          : 'Off',
                      style: GoogleFonts.outfit(fontSize: 12),
                    ),
                    trailing: Switch(
                      value: notificationSettings.dailyReminderEnabled,
                      onChanged: (val) {
                        ref.read(notificationSettingsProvider.notifier).setDailyReminderEnabled(val);
                      },
                    ),
                  ),
                  if (notificationSettings.dailyReminderEnabled) ...[
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(Icons.schedule_rounded, color: theme.colorScheme.primary),
                      title: Text(
                        'Reminder time',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                      subtitle: Text(
                        notificationSettings.dailyReminderLabel,
                        style: GoogleFonts.outfit(fontSize: 12),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay(
                            hour: notificationSettings.dailyReminderHour,
                            minute: notificationSettings.dailyReminderMinute,
                          ),
                        );
                        if (picked != null) {
                          await ref.read(notificationSettingsProvider.notifier).setDailyReminderTime(
                                hour: picked.hour,
                                minute: picked.minute,
                              );
                        }
                      },
                    ),
                  ],
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.pending_actions_outlined, color: theme.colorScheme.primary),
                    title: Text(
                      'Unfinished test reminder',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                    subtitle: Text(
                      'Notify you 2 hours after leaving a quiz early',
                      style: GoogleFonts.outfit(fontSize: 12),
                    ),
                    trailing: Switch(
                      value: notificationSettings.unfinishedReminderEnabled,
                      onChanged: (val) {
                        ref
                            .read(notificationSettingsProvider.notifier)
                            .setUnfinishedReminderEnabled(val);
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 3. Settings Group: Data & Storage
              _buildSectionTitle(context, 'Storage & Offline Sync'),
              const SizedBox(height: 8),
              _buildSettingsCard(
                context: context,
                children: [
                  ListTile(
                    leading: Icon(
                      offlineReady ? Icons.offline_pin_rounded : Icons.cloud_off_outlined,
                      color: offlineReady ? const Color(0xFF00A896) : theme.colorScheme.primary,
                    ),
                    title: Text(
                      offlineReady ? 'Offline content ready' : 'Offline content pending',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                    subtitle: Text(
                      lastSync == null
                          ? 'Questions, signs & highway code stored in Hive'
                          : 'Last sync: ${lastSync.day}/${lastSync.month}/${lastSync.year} ${lastSync.hour}:${lastSync.minute.toString().padLeft(2, '0')}',
                      style: GoogleFonts.outfit(fontSize: 12),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.cloud_sync_outlined, color: theme.colorScheme.primary),
                    title: Text(
                      'Sync Content Now',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                    subtitle: Text(
                      'Download latest questions, signs & rules',
                      style: GoogleFonts.outfit(fontSize: 12),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final result = await ref.read(offlineSyncServiceProvider).syncAll();
                      if (!context.mounted) return;
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            'Synced: ${result.questions.count} questions, '
                            '${result.roadSigns.count} signs, '
                            '${result.highwayCode.count} highway rules',
                          ),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 4. Logout / Authenticate actions
              ElevatedButton.icon(
                onPressed: () async {
                  await ref.read(authProvider.notifier).logout();
                  if (context.mounted) {
                    context.go('/login');
                  }
                },
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: Text(
                  authState == AuthState.guest ? 'Exit Guest Mode' : 'Sign Out',
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent.withAlpha(20),
                  foregroundColor: Colors.redAccent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: Colors.redAccent, width: 1),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Widget for Category Title
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  // Wrapper card container for groupings
  Widget _buildSettingsCard({
    required BuildContext context,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? Colors.white.withAlpha(15) : Colors.black.withAlpha(10),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 20 : 5),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          children: children,
        ),
      ),
    );
  }
}
