import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

class SideMenu extends ConsumerWidget {
  const SideMenu({Key? key}) : super(key: key);

  // 共通化されたメニュー項目を生成する関数
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      tileColor: Colors.blue.shade800, // 通常状態の背景色
      hoverColor: Colors.blue.shade200, // ホバー時の背景色を明るい青に設定
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider); // 認証情報を取得

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          authState.when(
            data: (auth) {
              // `auth`が`SignedIn`の場合にのみ`name`や`email`を表示
              if (auth is SignedIn) {
                return UserAccountsDrawerHeader(
                  accountName: Text(auth.name),
                  accountEmail: Text(auth.email),
                  currentAccountPicture: CircleAvatar(
                    child: Text(auth.name.isNotEmpty ? auth.name[0] : '?'),
                  ),
                );
              } else {
                return const UserAccountsDrawerHeader(
                  accountName: Text('Guest'),
                  accountEmail: Text('Please log in'),
                  currentAccountPicture: CircleAvatar(
                    child: Text('?'),
                  ),
                );
              }
            },
            loading: () => const UserAccountsDrawerHeader(
              accountName: Text('Loading...'),
              accountEmail: Text('Please wait'),
              currentAccountPicture: CircleAvatar(
                child: CircularProgressIndicator(),
              ),
            ),
            error: (error, _) => UserAccountsDrawerHeader(
              accountName: Text('Error'),
              accountEmail: Text(error.toString()),
              currentAccountPicture: const CircleAvatar(
                child: Icon(Icons.error),
              ),
            ),
          ),
          // Dashboardメニュー
          _buildMenuItem(
            icon: Icons.dashboard,
            title: 'Dashboard',
            onTap: () => context.go('/dashboard'),
          ),
          // Inventoryメニュー
          _buildMenuItem(
            icon: Icons.inventory,
            title: 'Inventory',
            onTap: () => context.go('/inventory'),
          ),
          // Settingsメニュー
          _buildMenuItem(
            icon: Icons.settings,
            title: 'Settings',
            onTap: () => context.go('/settings'),
          ),
          // ログイン中の場合のみ表示されるサインアウトメニュー
          if (authState.asData?.value != null)
            _buildMenuItem(
              icon: Icons.logout,
              title: 'Logout',
              onTap: () async {
                await ref.read(authNotifierProvider.notifier).signOut();
                context.go('/login');
              },
            )
        ],
      ),
    );
  }
}
