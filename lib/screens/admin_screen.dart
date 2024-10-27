// lib/screens/admin_screen.dart
import 'package:flutter/material.dart';
import '../widgets/main_layout.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Admin Page', // ページのタイトル
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'Admin Panel',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'This page is only accessible by administrators.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
