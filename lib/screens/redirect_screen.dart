// lib/screens/redirect_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

class RedirectScreen extends ConsumerStatefulWidget {
  const RedirectScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<RedirectScreen> createState() => _RedirectScreenState();
}

class _RedirectScreenState extends ConsumerState<RedirectScreen> {
  @override
  void initState() {
    super.initState();
    _handleAuthRedirect();
  }

  // Handling authentication redirects
  Future<void> _handleAuthRedirect() async {
    final uri = Uri.base;

    // Execute authentication redirect processing
    await ref.read(authNotifierProvider.notifier).handleAuthRedirect(uri);

    // Once authentication is complete, you will be redirected to the homepage
    if (mounted) {
      // context.go('/');
      context.go('/inventory');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child:
            CircularProgressIndicator(), // Loading display during authentication process
      ),
    );
  }
}
