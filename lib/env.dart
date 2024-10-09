// lib/env.dart

import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get clientId => dotenv.env['CLIENT_ID']!;
  static String get clientSecret => dotenv.env['CLIENT_SECRET']!;
  static String get authUrl => dotenv.env['AUTH_URL']!;
  static String get tokenUrl => dotenv.env['TOKEN_URL']!;
  static String get redirectUri => dotenv.env['REDIRECT_URI']!;
  static String get userInfoUrl => dotenv.env['USERINFO_URL']!;
}
