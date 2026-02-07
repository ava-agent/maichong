import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../pages/welcome_page.dart';
import '../pages/timeline/timeline_page.dart';
import '../pages/settings/settings_page.dart';
import '../widgets/common/bottom_nav_shell.dart';

enum AppRoute {
  welcome,
  timeline,
  settings,
}

final goRouter = GoRouter(
  initialLocation: '/welcome',
  routes: [
    // Welcome page (no bottom nav)
    GoRoute(
      path: '/welcome',
      name: AppRoute.welcome.name,
      builder: (context, state) => const WelcomePage(),
    ),
    // Main app with bottom navigation
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          MainShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/timeline',
              name: AppRoute.timeline.name,
              builder: (context, state) => const TimelinePage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              name: AppRoute.settings.name,
              builder: (context, state) => const SettingsPage(),
            ),
          ],
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('页面未找到: ${state.uri}'),
    ),
  ),
);
