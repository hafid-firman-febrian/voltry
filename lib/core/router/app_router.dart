import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../features/analysis/presentation/pages/analyze_page.dart';
import '../../features/meal_log/presentation/pages/history_page.dart';
import '../../features/meal_log/presentation/pages/home_page.dart';
import '../../features/meal_log/presentation/pages/meal_detail_page.dart';
import 'app_routes.dart';
import 'app_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: AppRoutes.home,
    // Stage 2 adds the sign-in check here, as a top-level redirect.
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (_, _) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.history,
                builder: (_, _) => const HistoryPage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.analyze,
        // The photo only travels in `extra`, which is lost on a cold start
        // from a saved location. Without it there is nothing to analyze.
        redirect: (_, state) => state.extra is XFile ? null : AppRoutes.home,
        builder: (_, state) => AnalyzePage(photo: state.extra! as XFile),
      ),
      GoRoute(
        path: AppRoutes.mealPattern,
        builder: (_, state) => MealDetailPage(id: state.pathParameters['id']!),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
