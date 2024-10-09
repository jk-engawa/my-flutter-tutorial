import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:html' as html;
import 'package:oauth2/oauth2.dart' as oauth2;
import 'env.dart';

class AuthService {
  final oauth2.AuthorizationCodeGrant _grant;
  oauth2.Client? _client; // トークンを保持するクライアント
  Map<String, dynamic>? _userInfo; // ユーザー情報

  AuthService()
      : _grant = oauth2.AuthorizationCodeGrant(
          Env.clientId,
          Uri.parse(Env.authUrl),
          Uri.parse(Env.tokenUrl),
          httpClient: http.Client(),
          // secret: Env.clientSecret,
        );

  // 認証URLを取得し、子ウィンドウを開く
  Future<void> initiateLogin() async {
    final authorizationUrl = _grant.getAuthorizationUrl(
        Uri.parse(Env.redirectUri),
        scopes: ['openid', 'profile', 'email']);
    html.window.open(
        authorizationUrl.toString(), 'OAuth2 Login', 'width=800,height=600');
  }

  // トークン取得処理
  Future<void> handleAuthorizationResponse(String authorizationCode) async {
    _client =
        await _grant.handleAuthorizationResponse({'code': authorizationCode});
    print('Access Token: ${_client?.credentials.accessToken}');
    await _fetchUserInfo();
  }

  // /userinfo からユーザー情報を取得
  Future<void> _fetchUserInfo() async {
    if (_client != null) {
      final response = await _client!.get(Uri.parse(Env.userInfoUrl));
      if (response.statusCode == 200) {
        _userInfo = json.decode(response.body);
        print('ユーザー情報: $_userInfo');
      } else {
        print('ユーザー情報の取得に失敗しました: ${response.statusCode}');
      }
    }
  }

  // ユーザー名の取得
  Map<String, dynamic>? getUserInfo() {
    return _userInfo;
  }
}
