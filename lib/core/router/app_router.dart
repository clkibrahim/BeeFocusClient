import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/reports/presentation/pages/reports_page.dart';
import '../../features/subjects/presentation/pages/subjects_page.dart';
import '../../features/timer/presentation/pages/timer_page.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    routes: [
      GoRoute(
        path: '/',
        name: 'timer',
        builder: (context, state) => const TimerPage(),
      ),
      GoRoute(
        path: '/subjects',
        name: 'subjects',
        builder: (context, state) => const SubjectsPage(),
      ),
      GoRoute(
        path: '/reports',
        name: 'reports',
        builder: (context, state) => const ReportsPage(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfilePage(),
      ),
    ],
  );
});
