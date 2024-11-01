// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import '../widgets/main_layout.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MainLayout(
      title: 'Dashboard Page',
      child: Center(child: Text('Dashboard Screen')),
    );
  }
}
