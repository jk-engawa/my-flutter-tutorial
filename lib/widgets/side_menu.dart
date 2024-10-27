import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

class SideMenu extends ConsumerWidget {
  const SideMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider); // 認証情報を取得

    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blueAccent,
            ),
            child: Text(
              'Menu',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          _buildMenuItem(context, 'Dashboard', Icons.dashboard, '/dashboard'),
          if (user?.role == 'admin') // 管理者のみ表示
            _buildMenuItem(
                context, 'Admin Panel', Icons.admin_panel_settings, '/admin'),
          _buildMenuItem(context, 'Inventory', Icons.inventory, '/inventory'),
          _buildMenuItem(context, 'Settings', Icons.settings, '/settings'),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
      BuildContext context, String title, IconData icon, String route) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      tileColor: Colors.blue.shade800, // 通常状態の背景色
      hoverColor: Colors.blue.shade200, // ホバー時の背景色を明るい青に設定
      onTap: () {
        context.go(route);
        Navigator.pop(context); // メニューを閉じる
      },
    );
  }
}
