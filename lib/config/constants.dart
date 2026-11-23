import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  static const String appName = 'PawPaw Admin Console';
  static const String appVersion = '1.0.0';

  static String get baseUrl => dotenv.env['BASE_URL'] ?? 'http://127.0.0.1:3001/api/';
  static String get apiKey =>
      dotenv.env['API_KEY'] ??
      'eQlpRPp6kCB0Ti1eXxUk7ZY0rXDW@cDW2cxCJiewjdh9jckHJCiw9812jVdgfpF1TD!FGzHpX0Zzc0w2VwzhTQkmgt1RiKn';

  static const String tokenKey = 'pawpaw_admin_token';
  static const String adminUserKey = 'pawpaw_admin_user';
}

