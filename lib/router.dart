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

// GoRouterの設定を関数で返す
@riverpod
GoRouter createRouter(CreateRouterRef ref) {
  // final auth = ref.watch(authNotifierProvider);
  // final isAuth = ValueNotifier<AsyncValue<OAuthUser?>>(const AsyncData(null));
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

      // 実質的な遷移処理はここから
      final auth = isAuth.value.requireValue;
      print(auth);

      if (state.fullPath!.startsWith('/redirect')) {
        print('/redirect');
        return null;
      }

      // if (auth) {
      //   print('please relogin');
      //   return '/login';
      // }

      // if (isAuth.value.isLoading || !isAuth.value.hasValue) {
      // if (!isAuth.value.hasValue) {
      //   print('/redirect');
      //   return '/redirect';
      // }

      // if (state.fullPath == '/redirect') {
      //   print('redirect ok? ${auth ? '/' : 'login'}');
      //   return auth ? '/' : 'login';
      // }

      // if (state.fullPath == '/login') {
      //   print('login ok? ${auth ? '/' : 'login'}');
      //   return auth ? '/' : null;
      // }
      print('others');
      return auth ? null : '/login';
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      // OAuth認証後のコールバックページ
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
