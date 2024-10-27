// lib/widgets/main_layout.dart
import 'package:flutter/material.dart';
import 'side_menu.dart';

class MainLayout extends StatelessWidget {
  final Widget child; // メインコンテンツとなるウィジェットを渡すためのプロパティ

  const MainLayout({required this.child, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Management System'),
      ),
      drawer: const SideMenu(), // ドロワーメニューとしてサイドメニューを追加
      body: child, // メインコンテンツエリア
    );
  }
}
