// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Management System'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await auth.signInWithOAuth(); // OAuth
          },
          child: const Text('Sign in with OAuth'),
        ),
      ),
    );
  }
}
