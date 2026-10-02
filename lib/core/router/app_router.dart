import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/meal_log/presentation/pages/home_page.dart';
import 'app_routes.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: AppRoutes.home,
    // Stage 2 adds the sign-in check here, as a top-level redirect.
    routes: [
      GoRoute(path: AppRoutes.home, builder: (_, _) => const HomePage()),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
