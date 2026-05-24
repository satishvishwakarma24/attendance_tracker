import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/config/constant/app_config.dart';
import '/core/theme/app_theme.dart';
import '/core/theme/theme_provider.dart';
import '../widgets/module_responsive.dart';
import '/modules/common/providers/session_provider.dart';
import 'package:url_launcher/url_launcher.dart';

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
          SizedBox(height: 24.h),
           Text('Develop By', style: text.labelSmall),
          SizedBox(height: 8.h),
         Card(
  elevation: 0,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(18.r),
    side: BorderSide(color: colors.outlineVariant),
  ),
  child: Column(
    children: [
      // Profile
      ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 8.h,
        ),
        leading: CircleAvatar(
          radius: 24.r,
          backgroundColor: colors.primaryContainer,
          child: Icon(
            Icons.person,
            color: colors.primary,
          ),
        ),
        title: Text(
          'Satish Vishwakarma',
          style: text.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: SelectableText(
          'satish.vishwakarma.it@gmail.com',
          style: text.bodyMedium,
        ),
      ),

      Divider(height: 1, color: colors.outlineVariant),

    
      Divider(height: 1, color: colors.outlineVariant),

      // GitHub
      ListTile(
        leading: Icon(
          Icons.code,
          color: colors.primary,
        ),
        title: Text(
          'GitHub',
          style: text.titleMedium,
        ),
        subtitle: Text(
          'github.com/satishvishwakarma24',
          style: text.bodySmall,
        ),
        trailing: Icon(
          Icons.open_in_new,
          size: 18.sp,
          color: colors.primary,
        ),
        onTap: () async {
          launchUrl(
            Uri.parse(
              'https://github.com/satishvishwakarma24/',
            ),
            mode: LaunchMode.externalApplication,
          );
        },
      ),

      Divider(height: 1, color: colors.outlineVariant),

      // Portfolio
      ListTile(
        leading: Icon(
          Icons.web_outlined,
          color: colors.primary,
        ),
        title: Text(
          'Portfolio',
          style: text.titleMedium,
        ),
        subtitle: Text(
          'satishvishwakarma24.github.io',
          style: text.bodySmall,
        ),
        trailing: Icon(
          Icons.open_in_new,
          size: 18.sp,
          color: colors.primary,
        ),
        onTap: () async {
          launchUrl(
            Uri.parse(
              // 'https://satishvishwakarma24.github.io/satishvishwakarma24/',
              'https://satishvishwakarma24.github.io/portfolio',
            ),
            mode: LaunchMode.externalApplication,
          );
        },
      ),

      Divider(height: 1, color: colors.outlineVariant),

      // LinkedIn
      ListTile(
        leading: Icon(
          Icons.business_center_outlined,
          color: colors.primary,
        ),
        title: Text(
          'LinkedIn',
          style: text.titleMedium,
        ),
        subtitle: Text(
          'linkedin.com/in/satish-vishwakarma',
          style: text.bodySmall,
        ),
        trailing: Icon(
          Icons.open_in_new,
          size: 18.sp,
          color: colors.primary,
        ),
        onTap: () async {
          launchUrl(
            Uri.parse(
              'https://linkedin.com/in/satish-vishwakarma',
            ),
            mode: LaunchMode.externalApplication,
          );
        },
      ),
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
