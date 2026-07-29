import 'package:dotenv/dotenv.dart';

class Env {
  static late DotEnv _dotenv;

  static void init() {
    _dotenv = DotEnv(includePlatformEnvironment: true)..load();
  }

  static String get(String key, {String defaultValue = ''}) {
    return _dotenv[key] ?? defaultValue;
  }

  static int getInt(String key, {int defaultValue = 0}) {
    final value = _dotenv[key];
    if (value == null) return defaultValue;
    return int.tryParse(value) ?? defaultValue;
  }

  static String get port => get('PORT', defaultValue: '8080');
  static String get host => get('HOST', defaultValue: '0.0.0.0');
  static String get jwtSecret => get('JWT_SECRET', defaultValue: 'default_jwt_secret');
  static String get databaseUrl => get('DATABASE_URL', defaultValue: '');
  static String get supabaseUrl => get('SUPABASE_URL', defaultValue: '');
  static String get supabaseKey => get('SUPABASE_KEY', defaultValue: '');
}
