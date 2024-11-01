// lib/providers/auth_provider.dart
//import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:oauth2/oauth2.dart' as oauth2;

part 'auth_provider.g.dart';
part 'auth_provider.freezed.dart';

@freezed
sealed class Auth with _$Auth {
  const factory Auth.signedIn({
    required String email,
    required String name,
    // required String token,
    required oauth2.Client client,
  }) = SignedIn;
  const Auth._();
  const factory Auth.signedOut() = SignedOut;
  bool get isAuth => switch (this) {
        SignedIn() => true,
        SignedOut() => false,
      };
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
        await _secureStorage.write(
            key: 'client', value: signedIn.client.credentials.toJson());
      }, signedOut: (signedOut) async {
        await _secureStorage.delete(key: 'client');
      });
    });
  }

  // Check auth client and initialize authentication state
  Future<Auth> _initializeAuthState() async {
    final oauth2ClientJson = await _secureStorage.read(key: 'client');
    try {
      if (oauth2ClientJson == null) throw Exception('No auth token found');
      final oauth2Client =
          oauth2.Client(oauth2.Credentials.fromJson(oauth2ClientJson));
      final userInfo = await _authService.fetchUserInfoNew(oauth2Client);
      print(userInfo.toString());
      return Auth.signedIn(
          name: userInfo['name'],
          email: userInfo['email'],
          client: oauth2Client);
    } catch (e) {
      print(e);
      // Logout process in case of error.
      await signOut();
      return Future.value(const Auth.signedOut());
    }
  }

  // Process to get auth client from authorization code
  Future<void> handleAuthRedirect(Uri uri) async {
    final params = uri.queryParameters;
    if (params['code'] != null) {
      try {
        final oauth2Client = await _authService.handleAuthorizationCode(params);
        await _secureStorage.write(
            key: 'client', value: oauth2Client.credentials.toJson());
        final userInfo = await _authService.fetchUserInfoNew(oauth2Client);
        print(userInfo);
        state = AsyncData(Auth.signedIn(
            name: userInfo['name'],
            email: userInfo['email'],
            client: oauth2Client));
      } catch (e, s) {
        print('Error during callback handling: $e');
        state = const AsyncData(Auth.signedOut());
      }
    }
  }

  Future<void> signInWithOAuth() async {
    await _authService.login();
  }

  Future<void> signOut() async {
    state = const AsyncData(Auth.signedOut());
    await _secureStorage.delete(key: 'client');
  }
}
