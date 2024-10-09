import 'package:flutter/material.dart';
import 'dart:html' as html;

class RedirectPage extends StatelessWidget {
  final String? code;

  RedirectPage({this.code});

  @override
  Widget build(BuildContext context) {
    // ページが読み込まれたときに、親ウィンドウにcodeを送信し、子ウィンドウを閉じる
    if (code != null) {
      html.window.opener?.postMessage({'code': code}, '*');
      html.window.close(); // 子ウィンドウを閉じる
    }

    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
