// lib/service/auth_service.dart
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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

  // PKCE用のコードチャレンジを生成
  String _generateCodeChallenge() {
    final codeVerifier =
        List.generate(128, (index) => Random.secure().nextInt(256));
    _codeVerifier = base64UrlEncode(codeVerifier)
        .replaceAll('=', '')
        .replaceAll('+', '-')
        .replaceAll('/', '_')
        .substring(0, 128); // 最大128文字に収める
    final bytes = sha256.convert(utf8.encode(_codeVerifier)).bytes;
    return base64UrlEncode(bytes).replaceAll('=', '');
  }

  // CSRF対策のstateを生成
  String _generateState() {
    final random = Random.secure();
    _state = List.generate(16, (index) => random.nextInt(256))
        .map((e) => e.toRadixString(16).padLeft(2, '0'))
        .join();
    return _state;
  }

  // 認証ページにリダイレクト
  Future<void> authenticate() async {
    final codeChallenge = _generateCodeChallenge();
    final state = _generateState();

    // 認可リクエストに使用するcodeVerifierとstateをStorageに保存
    await _secureStorage.write(
        key: 'oauth_code_verifier', value: _codeVerifier);
    await _secureStorage.write(key: 'oauth_state', value: _state);

    final authorizationUrl = Uri.parse('$authorizationEndpoint'
        '?client_id=$clientId'
        '&redirect_uri=$redirectUri'
        '&response_type=code'
        '&scope=openid profile email'
        '&code_challenge_method=S256'
        '&code_challenge=$codeChallenge'
        '&state=$state');

    if (await canLaunchUrl(authorizationUrl)) {
      await launchUrl(authorizationUrl,
          mode: LaunchMode.externalApplication, webOnlyWindowName: '_self');
    } else {
      throw Exception('Could not launch $authorizationUrl');
    }
  }

  // 認可コードをトークンと交換
  Future<Map<String, dynamic>> exchangeCodeForToken(
      String authCode, String state) async {
    // localStorageからcodeVerifierとstateを取得して検証
    final storedCodeVerifier =
        await _secureStorage.read(key: 'oauth_code_verifier');
    final storedState = await _secureStorage.read(key: 'oauth_state');

    if (state != storedState) {
      throw Exception('Invalid state parameter'); // state検証
    }

    // 使用後にlocalStorageから削除
    await _secureStorage.delete(key: 'oauth_code_verifier');
    await _secureStorage.delete(key: 'oauth_state');

    final response = await http.post(
      Uri.parse(tokenEndpoint),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'client_id': clientId,
        'redirect_uri': redirectUri,
        'grant_type': 'authorization_code',
        'code': authCode,
        'code_verifier': storedCodeVerifier!,
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to exchange code for token');
    }
  }

  // ユーザー情報を取得
  Future<Map<String, dynamic>> fetchUserInfo(String accessToken) async {
    final response = await http.get(
      Uri.parse(userInfoEndpoint),
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch user info');
    }
  }
}
