import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '/config/constant/app_config.dart';
import '/config/routes/routes_name.dart';
import '/core/theme/app_theme.dart';
import '/modules/auth/providers/auth_providers.dart';
import '/modules/common/module_responsive.dart';
/// Role-based navigation drawer for authenticated screens.
class AppNavBar extends ConsumerWidget {
  const AppNavBar({
    super.key,
    required this.currentRoute,
  });

  final String currentRoute;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final text = context.textStyles;
    final profile = ref.watch(userProfileProvider).value;
    final isAdmin = ref.watch(isSuperAdminProvider);

    final displayName = profile?.displayName ??
        profile?.email.split('@').first ??
        'User';

    void go(String route) {
      Navigator.of(context).pop();
      if (currentRoute != route) {
        context.go(route);
      }
    }

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DrawerHeader(
              margin: EdgeInsets.zero,
              padding: ModuleResponsive.screenPadding,
              decoration: BoxDecoration(
                color: colors.primaryContainer,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 28.r,
                    backgroundColor: colors.primary,
                    child: Text(
                      displayName.isNotEmpty
                          ? displayName[0].toUpperCase()
                          : '?',
                      style: text.titleLarge?.copyWith(
                        color: colors.onPrimary,
                        fontSize: 22.sp,
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    displayName,
                    style: text.titleMedium?.copyWith(fontSize: 18.sp),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (profile?.email.isNotEmpty == true) ...[
                    SizedBox(height: 4.h),
                    Text(
                      profile!.email,
                      style: text.bodySmall?.copyWith(fontSize: 12.sp),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  SizedBox(height: 6.h),
                  Text(
                    isAdmin ? 'Super Admin' : 'Employee',
                    style: text.labelSmall?.copyWith(
                      color: colors.primary,
                      fontSize: 11.sp,
                    ),
                  ),
                ],
              ),
            ),
            _NavTile(
              icon: Icons.dashboard_outlined,
              selectedIcon: Icons.dashboard,
              label: 'Dashboard',
              selected: currentRoute == RoutesName.dashboard,
              onTap: () => go(RoutesName.dashboard),
            ),
            if (isAdmin)
              _NavTile(
                icon: Icons.location_on_outlined,
                selectedIcon: Icons.location_on,
                label: 'Location List',
                selected: currentRoute == RoutesName.locations ||
                    currentRoute == RoutesName.addLocation,
                onTap: () => go(RoutesName.locations),
              )
            else
              _NavTile(
                icon: Icons.history_outlined,
                selectedIcon: Icons.history,
                label: 'User History',
                selected: currentRoute == RoutesName.userHistory,
                onTap: () => go(RoutesName.userHistory),
              ),
            _NavTile(
              icon: Icons.settings_outlined,
              selectedIcon: Icons.settings,
              label: 'Settings',
              selected: currentRoute == RoutesName.settings,
              onTap: () => go(RoutesName.settings),
            ),
            const Spacer(),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
              child: Text(
                'v${AppConfig.appVersion}',
                style: text.bodySmall?.copyWith(fontSize: 11.sp),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textStyles;

    return ListTile(
      leading: Icon(
        selected ? selectedIcon : icon,
        color: selected ? colors.primary : colors.onSurfaceVariant,
        size: 24.sp,
      ),
      title: Text(
        label,
        style: text.labelLarge?.copyWith(
          fontSize: 15.sp,
          color: selected ? colors.primary : colors.onSurface,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
        ),
      ),
      selected: selected,
      selectedTileColor: colors.primaryContainer.withValues(alpha: 0.35),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      onTap: onTap,
    );
  }
}
