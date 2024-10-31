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

  // 認証リダイレクトの処理
  Future<void> _handleAuthRedirect() async {
    final uri = Uri.base;

    // 認証リダイレクト処理を実行
    await ref.read(authNotifierProvider.notifier).handleAuthRedirect(uri);

    // 認証が完了したらホームページに遷移
    if (mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // 認証処理中にローディング表示
      ),
    );
  }
}
