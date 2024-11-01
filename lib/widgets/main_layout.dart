// lib/widgets/main_layout.dart
import 'package:flutter/material.dart';
import 'side_menu.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  final String title;

  const MainLayout({required this.child, required this.title, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title), // Display title for each page
      ),
      drawer: const SideMenu(), // Add side menu as drawer menu
      body: child, // Main content area
    );
  }
}
