// lib/router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/inventory_screen.dart';
import 'screens/settings_screen.dart';
// import 'screens/admin_screen.dart';

// GoRouterの設定を関数で返す
GoRouter createRouter(WidgetRef ref) {
  final auth = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      // 未ログインかつログインページでない場合、ログイン画面にリダイレクト
      if (auth == null && state.path != '/login') {
        return '/login';
      }
      return null; // リダイレクト不要
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
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
          // GoRoute(
          //   path: 'admin',
          //   builder: (context, state) => const AdminScreen(),
          // ),
        ],
      ),
      // OAuth認証後のコールバックページ
      GoRoute(
        path: '/redirect',
        builder: (context, state) {
          final uri = Uri.parse(state.path!);
          ref.read(authProvider.notifier).handleAuthRedirect(uri);
          // 認証後、ホーム画面などにリダイレクト
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },
      ),
    ],
  );
}
