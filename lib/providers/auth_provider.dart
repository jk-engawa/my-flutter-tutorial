// lib/providers/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import 'dart:html' as html;

final authProvider = StateNotifierProvider<AuthNotifier, OAuthUser?>((ref) {
  return AuthNotifier(AuthService());
});

class OAuthUser {
  final String name;
  final String email;

  OAuthUser(this.name, this.email);
}

class AuthNotifier extends StateNotifier<OAuthUser?> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(null);

  // 認可コード処理を実行
  Future<void> handleAuthRedirect(Uri uri) async {
    final code = uri.queryParameters['code'];
    final state = uri.queryParameters['state'];
    if (code != null && state != null) {
      try {
        final tokenData = await _authService.exchangeCodeForToken(code, state);
        final userInfo =
            await _authService.fetchUserInfo(tokenData['access_token']);
        this.state = OAuthUser(userInfo['name'], userInfo['email']);
        html.window.localStorage['is_authenticated'] = 'true';
      } catch (e) {
        print('Error during callback handling: $e');
      }
    }
  }

  Future<void> signInWithOAuth() async {
    await _authService.authenticate();
  }

  Future<void> signOut() async {
    state = null;
    html.window.localStorage.remove('is_authenticated');
  }
}
