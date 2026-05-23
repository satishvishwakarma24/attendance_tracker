import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/config/constant/app_config.dart';
import '/core/theme/app_theme.dart';
import '/core/theme/theme_provider.dart';
import '../widgets/module_responsive.dart';
import '/modules/common/providers/session_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final text = context.textStyles;
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    return ListView(
      padding: ModuleResponsive.screenPadding,
      children: [
          Text('Appearance', style: text.labelSmall),
          SizedBox(height: 8.h),
          Card(
            child: SwitchListTile(
              title: Text('Dark mode', style: text.titleMedium),
              subtitle: Text(
                isDark ? 'Dark theme enabled' : 'Light theme enabled',
                style: text.bodySmall,
              ),
              value: isDark,
              onChanged: (_) {
                ref.read(themeProvider.notifier).toggleTheme();
              },
            ),
          ),
          SizedBox(height: 24.h),
          Text('About', style: text.labelSmall),
          SizedBox(height: 8.h),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.info_outline, color: colors.primary),
                  title: Text('App version', style: text.titleMedium),
                  subtitle: Text(
                    AppConfig.appVersion,
                    style: text.bodyMedium,
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                    leading:
                        Icon(Icons.description_outlined, color: colors.primary),
                    title: Text('About', style: text.titleMedium),
                    subtitle: Text(
                      AppConfig.appDescription,
                      style: text.bodyMedium,
                    ),
                    onTap: () {}),
              ],
            ),
          ),
          SizedBox(height: 32.h),
          OutlinedButton.icon(
            onPressed: () => _confirmLogout(context, ref),
            icon: Icon(Icons.logout, size: 20.sp, color: colors.error),
            label: Text(
              'Sign out',
              style: text.labelLarge?.copyWith(color: colors.error),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: colors.error.withValues(alpha: 0.5)),
              padding: EdgeInsets.symmetric(vertical: 14.h),
            ),
          ),
        ],
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final text = context.textStyles;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Sign out?', style: text.titleLarge),
        content: Text(
          'Are you sure you want to Sign out?',
          style: text.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;
    await signOut(ref);
  }
}
