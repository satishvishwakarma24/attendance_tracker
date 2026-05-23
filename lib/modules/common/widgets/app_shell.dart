import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '/config/constant/app_config.dart';
import '/config/routes/routes_name.dart';
import '/core/theme/app_theme.dart';
import '/modules/auth/providers/auth_providers.dart';
import 'module_responsive.dart';
import '/modules/common/widgets/app_nav_bar.dart';

/// Single scaffold for bottom-nav tabs; preserves each tab with [IndexedStack].
class AppShell extends ConsumerWidget {
  const AppShell({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  static String titleForLocation(String location) {
    if (location.startsWith(RoutesName.locations)) {
      return 'Office Locations';
    }
    return switch (location) {
      RoutesName.dashboard => AppConfig.appName,
      RoutesName.userHistory => 'User History',
      RoutesName.settings => 'Settings',
      _ => AppConfig.appName,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = context.textStyles;
    final location = GoRouterState.of(context).uri.path;
    final isAdmin = ref.watch(isSuperAdminProvider);
    final title = titleForLocation(location);

    final showLocationsFab =
        isAdmin && navigationShell.currentIndex == 1;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: text.titleLarge?.copyWith(fontSize: 18.sp),
        ),
      ),
      body: navigationShell,
      floatingActionButton: showLocationsFab
          ? FloatingActionButton(
              onPressed: () => context.push(RoutesName.addLocation),
              child: Icon(Icons.add, size: 28.sp),
            )
          : null,
      bottomNavigationBar: AppNavBar(navigationShell: navigationShell),
    );
  }
}
