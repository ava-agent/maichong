import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../pages/welcome_page.dart';
import '../pages/timeline/timeline_page.dart';
import '../pages/settings/settings_page.dart';

enum AppRoute {
  welcome,
  timeline,
  settings,
}

final goRouter = GoRouter(
  initialLocation: '/welcome',
  routes: [
    GoRoute(
      path: '/welcome',
      name: AppRoute.welcome.name,
      builder: (context, state) => const WelcomePage(),
    ),
    GoRoute(
      path: '/timeline',
      name: AppRoute.timeline.name,
      builder: (context, state) => const TimelinePage(),
    ),
    GoRoute(
      path: '/settings',
      name: AppRoute.settings.name,
      builder: (context, state) => const SettingsPage(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('页面未找到: ${state.uri}'),
    ),
  ),
);
