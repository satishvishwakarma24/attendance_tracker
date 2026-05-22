import 'package:go_router/go_router.dart';
import '../../modules/view.dart';
import 'routes_name.dart';

class Routes {
  static final GoRouter router = GoRouter(
    initialLocation: RoutesName.login,
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
        builder: (context, state) => const AddLocationScreen(),
      ),
    ],
  );
}
