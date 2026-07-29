import 'package:supabase/supabase.dart';
import 'env.dart';

class DatabaseConfig {
  static SupabaseClient? _client;

  static SupabaseClient get client {
    if (_client == null) {
      throw Exception('Database/Supabase client has not been initialized. Call DatabaseConfig.initialize() first.');
    }
    return _client!;
  }

  static Future<void> initialize() async {
    final url = Env.supabaseUrl;
    final key = Env.supabaseKey;
    
    if (url.isEmpty || key.isEmpty) {
      print('Warning: SUPABASE_URL or SUPABASE_KEY is empty in .env');
    }

    _client = SupabaseClient(url, key);
    print('Initialized Supabase Client for $url');
  }

  static Future<void> close() async {
    _client = null;
    print('Closed database connection');
  }
}
