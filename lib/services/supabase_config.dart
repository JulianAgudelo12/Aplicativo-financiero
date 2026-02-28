import 'package:supabase/supabase.dart';

class SupabaseConfig {
  static SupabaseClient? _client;

  static void initialize({
    required String url,
    required String anonKey,
  }) {
    _client ??= SupabaseClient(url, anonKey);
  }

  static SupabaseClient get client {
    final configured = _client;
    if (configured == null) {
      throw StateError(
        'Supabase client is not initialized. Call SupabaseConfig.initialize() in main().',
      );
    }
    return configured;
  }
}
