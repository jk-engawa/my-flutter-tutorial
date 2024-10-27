// lib/providers/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ユーザー情報クラス
class User {
  final String username;
  final String role; // 役割 (例: "admin" または "user")

  User(this.username, this.role);
}

// 認証プロバイダー
final authProvider = StateProvider<User?>((ref) => null);  // 初期状態は未ログイン