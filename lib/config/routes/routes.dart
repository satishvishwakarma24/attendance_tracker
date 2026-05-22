import 'package:go_router/go_router.dart';
import '../../modules/views/home_screen.dart';
import '../../modules/views/settings_screen.dart';
import 'routes_name.dart';

class Routes {
  Routes._();

  static final GoRouter router = GoRouter(
    initialLocation: RoutesName.home,
    routes: [
      GoRoute(
        path: RoutesName.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: RoutesName.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}
