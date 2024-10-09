// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'auth_service.dart';
import 'dart:html' as html;
import 'redirect_page.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  setUrlStrategy(PathUrlStrategy());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OAuth2 Login',
      theme: ThemeData(primarySwatch: Colors.blue),
      // onGenerateRoute を使ってクエリパラメータを処理
      onGenerateRoute: (settings) {
        Uri uri = Uri.parse(settings.name!);

        // /redirect にアクセスした際の処理
        if (uri.path == '/redirect') {
          final code = uri.queryParameters['code'];
          return MaterialPageRoute(
            builder: (context) => RedirectPage(
              code: code, // code を渡す
            ),
          );
        }

        // 初期ページ
        return MaterialPageRoute(
          builder: (context) => OAuth2LoginPage(authService: authService),
        );
      },
      initialRoute: '/', // 初期ルート
    );
  }
}

class OAuth2LoginPage extends StatefulWidget {
  final AuthService authService;

  OAuth2LoginPage({required this.authService});

  @override
  _OAuth2LoginPageState createState() => _OAuth2LoginPageState();
}

class _OAuth2LoginPageState extends State<OAuth2LoginPage> {
  String? userName;
  String? userImageUrl;

  @override
  void initState() {
    super.initState();

    // 親ウィンドウで子ウィンドウからのメッセージを受信
    html.window.onMessage.listen((event) async {
      final data = event.data;
      if (data != null && data['code'] != null) {
        final code = data['code'];
        print('認証コードを受信しました: $code');

        // 認証コードを使ってトークンを取得
        await widget.authService.handleAuthorizationResponse(code);

        // トークン取得後にユーザー情報を取得
        final userInfo = await widget.authService.getUserInfo();
        if (userInfo != null) {
          setState(() {
            userName = userInfo['name'];
            userImageUrl = userInfo['picture'];
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OAuth2 Login Parent Window'),
        actions: [
          if (userName != null && userImageUrl != null) ...[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(userImageUrl!), // ユーザーアイコン
                  ),
                  SizedBox(width: 10),
                  Text(userName!), // ユーザー名
                ],
              ),
            ),
          ]
        ],
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            widget.authService.initiateLogin(); // 子ウィンドウでログイン処理を開始
          },
          child: Text('ログイン'),
        ),
      ),
    );
  }
}
