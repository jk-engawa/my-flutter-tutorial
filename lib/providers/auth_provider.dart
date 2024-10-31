// lib/providers/auth_provider.dart
//import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

part 'auth_provider.g.dart';
part 'auth_provider.freezed.dart';

@freezed
sealed class Auth with _$Auth {
  const factory Auth.signedIn({
    required String email,
    required String name,
    required String token,
  }) = SignedIn;
  const Auth._();
  const factory Auth.signedOut() = SignedOut;
  bool get isAuth => switch (this) {
        SignedIn() => true,
        SignedOut() => false,
      };
}

class OAuthUser {
  final String name;
  final String email;

  const OAuthUser(this.name, this.email);
}

@riverpod
class AuthNotifier extends _$AuthNotifier {
  final AuthService _authService = AuthService();
  final _secureStorage = const FlutterSecureStorage();

  @override
  Future<Auth> build() async {
    _persistenceRefreshLogic();
    return await _initializeAuthState();
  }

  void _persistenceRefreshLogic() {
    ref.listenSelf((_, next) async {
      if (next.isLoading) return;
      if (next.hasError) {
        await signOut();
        return;
      }

      next.requireValue.map<void>(signedIn: (signedIn) async {
        await _secureStorage.write(key: 'access_token', value: signedIn.token);
      }, signedOut: (signedOut) async {
        await _secureStorage.delete(key: 'access_token');
      });
    });
  }

  // アクセストークンをチェックして認証状態を初期化
  Future<Auth> _initializeAuthState() async {
    final accessToken = await _secureStorage.read(key: 'access_token');
    try {
      // トークンが有効な場合のみユーザー情報を取得
      if (accessToken == null) throw Exception('No auth token found');
      final userInfo = await _authService.fetchUserInfo(accessToken);
      print(userInfo.toString());
      return Auth.signedIn(
          name: userInfo['name'], email: userInfo['email'], token: accessToken);
    } catch (_) {
      // トークンが無効であればログイン状態をクリア
      await signOut();
      return Future.value(const Auth.signedOut());
    }
  }

  // 認可コード処理を実行
  Future<void> handleAuthRedirect(Uri uri) async {
    final code = uri.queryParameters['code'];
    final state = uri.queryParameters['state'];
    if (code != null && state != null) {
      try {
        final tokenData = await _authService.exchangeCodeForToken(code, state);
        final accessToken = tokenData['access_token'];
        await _secureStorage.write(key: 'access_token', value: accessToken);
        final userInfo =
            await _authService.fetchUserInfo(tokenData['access_token']);
        print(userInfo);
        this.state = AsyncData(Auth.signedIn(
            name: userInfo['name'],
            email: userInfo['email'],
            token: accessToken));
      } catch (e, s) {
        print('Error during callback handling: $e');
        this.state = const AsyncData(Auth.signedOut());
      }
    }
  }

  Future<void> signInWithOAuth() async {
    await _authService.authenticate();
  }

  Future<void> signOut() async {
    state = const AsyncData(Auth.signedOut());
    await _secureStorage.delete(key: 'access_token');
  }
}
