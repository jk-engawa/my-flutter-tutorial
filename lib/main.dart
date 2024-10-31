// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'providers/auth_provider.dart';
import 'router.dart';
import 'dart:html' as html;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env"); // .envの読み込み
  usePathUrlStrategy();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    // final uri = Uri.base;
    // if (uri.path == '/redirect') {
    //   ref.read(authProvider.notifier).handleAuthRedirect(uri);
    // } else if (html.window.localStorage['is_authenticated'] == 'true') {
    //   // ログイン済みの場合のセッション検証
    //   ref.read(authProvider.notifier).signInWithOAuth();
    // }
  }

  @override
  Widget build(BuildContext context) {
    // GoRouterのインスタンスを取得
    final router = ref.watch(createRouterProvider);

    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      title: 'Inventory Management System',
      theme: ThemeData(primarySwatch: Colors.blue),
    );
  }
}
