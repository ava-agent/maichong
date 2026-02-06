import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../presentation/pages/welcome_page.dart';
import '../../presentation/pages/timeline/timeline_page.dart';
import '../../presentation/pages/settings/settings_page.dart';

part 'app_router.g.dart';

enum AppRoute {
  welcome,
  timeline,
  settings,
}

@riverpod
GoRouter goRouter(_) {
  return GoRouter(
    initialLocation: '/welcome',
    routes: $routes,
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('页面未找到: ${state.uri}'),
      ),
    ),
  );
}
