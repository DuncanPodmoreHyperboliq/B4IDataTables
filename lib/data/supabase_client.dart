import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String apiUrl = 'https://b4idb.hyperboliq.com';
  static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.ewogICJyb2xlIjogImFub24iLAogICJpc3MiOiAic3VwYWJhc2UiLAogICJpYXQiOiAxNzI1MjI4MDAwLAogICJleHAiOiAxODgyOTk0NDAwCn0.63amy88IpZsklIZEnYaSfCCUM3UsKc2rB_QgR0gG3nA';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: apiUrl,
      anonKey: anonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
