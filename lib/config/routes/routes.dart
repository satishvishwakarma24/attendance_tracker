import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../modules/auth/providers/auth_providers.dart';
import '../../modules/common/widgets/app_nav_bar.dart';
import '../../modules/common/widgets/app_shell.dart';
import '../../modules/view.dart';
import 'routes_name.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _RouterRefresh(ref);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: RoutesName.login,
    refreshListenable: refresh,
    redirect: (context, state) {
      final authAsync = ref.read(authStateProvider);
      final profileAsync = ref.read(userProfileProvider);

      if (authAsync.isLoading) return null;

      final user = authAsync.value;
      final path = state.uri.path;
      final isLogin = path == RoutesName.login;

      if (user == null) {
        return isLogin ? null : RoutesName.login;
      }

      if (isLogin) {
        return RoutesName.dashboard;
      }

      // Keep the current tab while profile loads to avoid redirect flicker.
      if (profileAsync.isLoading) {
        if (AppNavBar.isShellRoute(path) || path == RoutesName.login) {
          return null;
        }
        return null;
      }

      final isAdmin = profileAsync.value?.role.isSuperAdmin ?? false;
      final adminOnly = path == RoutesName.locations ||
          path == RoutesName.addLocation ||
          path == RoutesName.attendanceMonitor;

      if (adminOnly && !isAdmin) {
        return RoutesName.dashboard;
      }

      if (path == RoutesName.userHistory && isAdmin) {
        return RoutesName.locations;
      }

      if (path == RoutesName.locations && !isAdmin) {
        return RoutesName.userHistory;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: RoutesName.login,
        builder: (context, state) => const LoginScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutesName.dashboard,
                pageBuilder: (context, state) => _tabPage(
                  state: state,
                  child: const DashboardScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutesName.userHistory,
                pageBuilder: (context, state) => _tabPage(
                  state: state,
                  child: const UserHistoryScreen(),
                ),
              ),
              GoRoute(
                path: RoutesName.locations,
                pageBuilder: (context, state) => _tabPage(
                  state: state,
                  child: const LocationsScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutesName.settings,
                pageBuilder: (context, state) => _tabPage(
                  state: state,
                  child: const SettingsScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: RoutesName.addLocation,
        builder: (context, state) {
          final locationId = state.uri.queryParameters['id'];
          return AddLocationScreen(locationId: locationId);
        },
      ),
      GoRoute(
        path: RoutesName.attendanceMonitor,
        builder: (context, state) => const AttendanceMonitorScreen(),
      ),
    ],
  );
});

NoTransitionPage<void> _tabPage({
  required GoRouterState state,
  required Widget child,
}) {
  return NoTransitionPage<void>(
    key: state.pageKey,
    child: child,
  );
}

class _RouterRefresh extends ChangeNotifier {
  _RouterRefresh(this._ref) {
    _ref.listen(authStateProvider, (_, __) => notifyListeners());
    _ref.listen(userProfileProvider, (_, __) => notifyListeners());
  }

  final Ref _ref;
}
