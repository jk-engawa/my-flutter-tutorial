// lib/service/auth_service.dart
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import '../env.dart';

class AuthService {
  final String clientId = Env.clientId;
  final String redirectUri = Env.redirectUri;
  final String authorizationEndpoint = Env.authUrl;
  final String tokenEndpoint = Env.tokenUrl;
  final String userInfoEndpoint = Env.userInfoUrl;
  final _secureStorage = const FlutterSecureStorage();

  late String _codeVerifier;
  late String _state;

  // Randomly generate a 128 character string to be used as the PKCE code
  // verifier.
  static String _createCodeVerifier() {
    const String _charset =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';

    return List.generate(
      128,
      (i) => _charset[Random.secure().nextInt(_charset.length)],
    ).join();
  }

  // Generate state for CSRF
  String _generateState() {
    final random = Random.secure();
    _state = List.generate(16, (index) => random.nextInt(256))
        .map((e) => e.toRadixString(16).padLeft(2, '0'))
        .join();
    return _state;
  }

  // Redirect to login page on Auth service.
  Future<void> login() async {
    final codeVerifier = _createCodeVerifier();
    final state = _generateState();
    final authorizationUrl = oauth2.AuthorizationCodeGrant(clientId,
            Uri.parse(authorizationEndpoint), Uri.parse(tokenEndpoint),
            codeVerifier: codeVerifier)
        .getAuthorizationUrl(Uri.parse(redirectUri),
            scopes: ['openid', 'profile', 'email'], state: state);

    // 認可リクエストに使用するstateをStorageに保存
    await _secureStorage.write(key: 'oauth_code_verifier', value: codeVerifier);
    await _secureStorage.write(key: 'oauth_state', value: state);

    if (await canLaunchUrl(authorizationUrl)) {
      await launchUrl(authorizationUrl,
          mode: LaunchMode.externalApplication, webOnlyWindowName: '_self');
    } else {
      throw Exception('Could not launch $authorizationUrl');
    }
  }

  // Exchange authorization code for token
  Future<oauth2.Client> handleAuthorizationCode(
      Map<String, String> params) async {
    final storedCodeVerifier =
        await _secureStorage.read(key: 'oauth_code_verifier');
    final storedState = await _secureStorage.read(key: 'oauth_state');

    if (params['state'] != storedState) {
      throw Exception('Invalid state parameter'); // state検証
    }
    // Remove from localStorage after use
    await _secureStorage.delete(key: 'oauth_code_verifier');
    await _secureStorage.delete(key: 'oauth_state');

    final grant = await oauth2.AuthorizationCodeGrant(
        clientId, Uri.parse(authorizationEndpoint), Uri.parse(tokenEndpoint),
        codeVerifier: storedCodeVerifier);

    // this is dummy for setting state,
    var _ = grant.getAuthorizationUrl(Uri.parse(redirectUri),
        scopes: ['openid', 'profile', 'email'], state: storedState);

    final client = await grant.handleAuthorizationResponse(params);
    return client;
  }

  Future<Map<String, dynamic>> fetchUserInfoNew(oauth2.Client client) async {
    final baseRequest = http.Request('GET', Uri.parse(userInfoEndpoint));
    final streamResponse = await client.send(baseRequest);
    if (streamResponse.statusCode == 200) {
      final responseBytes = await streamResponse.stream.toBytes();
      final responseString = utf8.decode(responseBytes);
      return jsonDecode(responseString);
    } else {
      throw Exception('Failed to fetch user info');
    }
  }
}
