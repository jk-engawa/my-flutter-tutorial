// lib/widgets/main_layout.dart
import 'package:flutter/material.dart';
import 'side_menu.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  final String title; // タイトルプロパティを追加

  const MainLayout({required this.child, required this.title, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title), // 各ページごとのタイトルを表示
      ),
      drawer: const SideMenu(), // ドロワーメニューとしてサイドメニューを追加
      body: child, // メインコンテンツエリア
    );
  }
}
