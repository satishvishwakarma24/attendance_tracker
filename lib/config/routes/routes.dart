import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../modules/auth/providers/auth_providers.dart';
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
      final path = state.matchedLocation;
      final isLogin = path == RoutesName.login;

      if (user == null) {
        return isLogin ? null : RoutesName.login;
      }

      if (isLogin) {
        return RoutesName.dashboard;
      }

      if (profileAsync.isLoading) return null;

      final isAdmin = profileAsync.value?.role.isSuperAdmin ?? false;
      final adminOnly = path == RoutesName.locations ||
          path == RoutesName.addLocation ||
          path == RoutesName.attendanceMonitor;

      if (adminOnly && !isAdmin) {
        return RoutesName.dashboard;
      }

      if (path == RoutesName.userHistory && isAdmin) {
        return RoutesName.dashboard;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: RoutesName.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RoutesName.dashboard,
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: RoutesName.locations,
        builder: (context, state) => const LocationsScreen(),
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
      GoRoute(
        path: RoutesName.userHistory,
        builder: (context, state) => const UserHistoryScreen(),
      ),
      GoRoute(
        path: RoutesName.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});

class _RouterRefresh extends ChangeNotifier {
  _RouterRefresh(this._ref) {
    _ref.listen(authStateProvider, (_, __) => notifyListeners());
    _ref.listen(userProfileProvider, (_, __) => notifyListeners());
  }

  final Ref _ref;
}
