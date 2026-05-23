import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/config/constant/app_config.dart';
import '/config/routes/routes_name.dart';
import '/core/theme/app_theme.dart';
import '/core/theme/theme_provider.dart';
import '/modules/common/module_responsive.dart';
import '/modules/common/providers/session_provider.dart';
import '/modules/common/widgets/app_scaffold.dart';

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

    return AppScaffold(
      title: 'Settings',
      currentRoute: RoutesName.settings,
      body: ListView(
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
                  leading: Icon(Icons.description_outlined,
                      color: colors.primary),
                  title: Text('About', style: text.titleMedium),
                  subtitle: Text(
                    AppConfig.appDescription,
                    style: text.bodyMedium,
                  ),
                  onTap: () => _showAboutDialog(context),
                ),
              ],
            ),
          ),
          SizedBox(height: 32.h),
          OutlinedButton.icon(
            onPressed: () => _confirmLogout(context, ref),
            icon: Icon(Icons.logout, size: 20.sp, color: colors.error),
            label: Text(
              'Log out',
              style: text.labelLarge?.copyWith(color: colors.error),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: colors.error.withValues(alpha: 0.5)),
              padding: EdgeInsets.symmetric(vertical: 14.h),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    final text = context.textStyles;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppConfig.appName, style: text.titleLarge),
        content: Text(
          '${AppConfig.appDescription}\n\nVersion ${AppConfig.appVersion}',
          style: text.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final text = context.textStyles;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Log out?', style: text.titleLarge),
        content: Text(
          'Your current session will be saved with its duration.',
          style: text.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;
    await endUserSessionAndSignOut(ref);
  }
}
