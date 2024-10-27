// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import '../widgets/main_layout.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MainLayout(
      child: Center(child: Text('Settings Screen')),
    );
  }
}
