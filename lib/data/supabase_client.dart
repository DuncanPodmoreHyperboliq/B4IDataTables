import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // static const String apiUrl = 'https://b4idb.hyperboliq.com';
  // static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.ewogICJyb2xlIjogImFub24iLAogICJpc3MiOiAic3VwYWJhc2UiLAogICJpYXQiOiAxNzI1MjI4MDAwLAogICJleHAiOiAxODgyOTk0NDAwCn0.63amy88IpZsklIZEnYaSfCCUM3UsKc2rB_QgR0gG3nA';

  static const String apiUrl = 'https://jaqseualsscbvedmvfxc.supabase.co';
  static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImphcXNldWFsc3NjYnZlZG12ZnhjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjY2MDM3MjYsImV4cCI6MjA0MjE3OTcyNn0.1EGAdITzrvMLUk0N_IEGsBT6tYABlDbl_PKAHjpalVA';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: apiUrl,
      anonKey: anonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
