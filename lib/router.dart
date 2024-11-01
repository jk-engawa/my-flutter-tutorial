// lib/router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/inventory_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/redirect_screen.dart';

part 'router.g.dart';

@riverpod
GoRouter createRouter(CreateRouterRef ref) {
  final isAuth = ValueNotifier<AsyncValue<bool>>(const AsyncLoading());
  ref
    ..onDispose(isAuth.dispose)
    ..listen(
      authNotifierProvider
          .select((value) => value.whenData((value) => value.isAuth)),
      (_, next) {
        isAuth.value = next;
      },
    );

  return GoRouter(
    initialLocation: '/',
    refreshListenable: isAuth,
    redirect: (context, state) {
      print(isAuth.value);

      if (isAuth.value.unwrapPrevious().hasError) {
        print('isAuth.value.unwrapPrevious().hasError /login');
        return '/login';
      }

      if (isAuth.value.isLoading) {
        print('wait loading.');
        return null;
      }

      // The actual transition process starts here
      final auth = isAuth.value.requireValue;
      print(auth);

      if (state.fullPath!.startsWith('/redirect')) {
        print('/redirect');
        return null;
      }

      print('others');
      return auth ? null : '/login';
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      // Callback page after OAuth authentication
      GoRoute(
        path: '/redirect',
        builder: (context, state) => const RedirectScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: 'inventory',
            builder: (context, state) => const InventoryScreen(),
          ),
          GoRoute(
            path: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
}
