import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get clientId => dotenv.env['CLIENT_ID']!;
  static String get authUrl => dotenv.env['AUTHORIZATION_ENDPOINT']!;
  static String get tokenUrl => dotenv.env['TOKEN_ENDPOINT']!;
  static String get redirectUri => dotenv.env['REDIRECT_URI']!;
  static String get userInfoUrl => dotenv.env['USERINFO_ENDPOINT']!;
}
