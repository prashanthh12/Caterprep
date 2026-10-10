import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/client_preview/screens/client_preview_screen.dart';
import '../../features/create_list/screens/create_list_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/ingredients/screens/ingredient_list_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/saved_lists/screens/saved_lists_screen.dart';
import '../../features/templates/screens/templates_screen.dart';
import '../../features/welcome/screens/welcome_screen.dart';
import '../widgets/main_scaffold_with_nav.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/welcome',
  routes: [
    // Welcome Screen
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),

    // Bottom Navigation Shell
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainScaffoldWithNav(navigationShell: navigationShell);
      },
      branches: [
        // 0. Dashboard (Home)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dashboard',
              builder: (context, state) => const DashboardScreen(),
            ),
          ],
        ),

        // 1. Saved Lists
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/lists',
              builder: (context, state) => const SavedListsScreen(),
            ),
          ],
        ),

        // 2. Templates
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/templates',
              builder: (context, state) => const TemplatesScreen(),
            ),
          ],
        ),

        // 3. Profile & Settings
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),

    // Full-screen creation and review workflow
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/lists/:listId/edit',
      builder: (context, state) {
        final listId = state.pathParameters['listId'] ?? 'new';
        return CreateListScreen(listId: listId);
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/lists/:listId/items',
      builder: (context, state) {
        final listId = state.pathParameters['listId'] ?? '';
        return IngredientListScreen(listId: listId);
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/lists/:listId/preview',
      builder: (context, state) {
        final listId = state.pathParameters['listId'] ?? '';
        return ClientPreviewScreen(listId: listId);
      },
    ),
  ],
);
