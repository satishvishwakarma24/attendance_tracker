import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '/config/routes/routes_name.dart';
import '/core/theme/app_theme.dart';
import '/modules/auth/providers/auth_providers.dart';
import 'module_responsive.dart';

/// Role-based bottom navigation wired to [StatefulNavigationShell].
class AppNavBar extends ConsumerWidget {
  const AppNavBar({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  static bool isShellRoute(String route) {
    return route == RoutesName.dashboard ||
        route == RoutesName.locations ||
        route == RoutesName.userHistory ||
        route == RoutesName.settings;
  }

  void _onDestinationSelected(BuildContext context, WidgetRef ref, int index) {
    final currentPath = GoRouterState.of(context).uri.path;

    if (index == 1) {
      final isAdmin = ref.read(isSuperAdminProvider);
      final route =
          isAdmin ? RoutesName.locations : RoutesName.userHistory;
      if (navigationShell.currentIndex != 1) {
        navigationShell.goBranch(1);
      }
      if (currentPath != route) {
        context.go(route);
      }
      return;
    }

    if (navigationShell.currentIndex == index) return;
    navigationShell.goBranch(index);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final isAdmin = ref.watch(isSuperAdminProvider);
    final selectedIndex = navigationShell.currentIndex;

    final destinations = isAdmin
        ? <NavigationDestination>[
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined, size: 24.sp),
              selectedIcon: Icon(Icons.dashboard, size: 24.sp),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.location_on_outlined, size: 24.sp),
              selectedIcon: Icon(Icons.location_on, size: 24.sp),
              label: 'Locations',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined, size: 24.sp),
              selectedIcon: Icon(Icons.settings, size: 24.sp),
              label: 'Settings',
            ),
          ]
        : <NavigationDestination>[
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined, size: 24.sp),
              selectedIcon: Icon(Icons.dashboard, size: 24.sp),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.history_outlined, size: 24.sp),
              selectedIcon: Icon(Icons.history, size: 24.sp),
              label: 'History',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined, size: 24.sp),
              selectedIcon: Icon(Icons.settings, size: 24.sp),
              label: 'Settings',
            ),
          ];

    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) =>
          _onDestinationSelected(context, ref, index),
      backgroundColor: colors.surfaceContainerLowest,
      indicatorColor: colors.primaryContainer,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      destinations: destinations,
    );
  }
}
