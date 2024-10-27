// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider.notifier); // authProviderのnotifierを監視

    // コントローラを作成してユーザー名とパスワードを受け取る
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Management System'), // 固定のタイトル
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ユーザー名入力フィールド
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // パスワード入力フィールド
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true, // パスワードを非表示
            ),
            const SizedBox(height: 24),
            // ログインボタン
            ElevatedButton(
              onPressed: () {
                // 簡易的な認証処理
                if (usernameController.text == 'admin' &&
                    passwordController.text == 'password') {
                  auth.state =
                      User(usernameController.text, 'admin'); // 管理者としてログイン
                } else if (usernameController.text == 'user' &&
                    passwordController.text == 'password') {
                  auth.state =
                      User(usernameController.text, 'user'); // 一般ユーザーとしてログイン
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invalid credentials')),
                  );
                }
              },
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
