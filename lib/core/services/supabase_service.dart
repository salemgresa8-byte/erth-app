import 'package:supabase_flutter/supabase_flutter.dart';

/// Thin wrapper around Supabase initialization and the shared client.
///
/// The anon key is a public, client-side key: it is safe to ship in the app
/// because access is enforced by Row Level Security (see supabase_schema.sql).
class SupabaseService {
  SupabaseService._();

  static const String url = 'https://qosvanmgszuipkpqzrvy.supabase.co';
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFvc3Zhbm1nc3p1aXBrcHF6cnZ5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTM2NDQzODQsImV4cCI6MjEwOTIyMDM4NH0.j7uHbVEB-A0DTQSeLj6diqxVt7Dp4s2kKQoMOSNgMpI';

  static Future<void> init() async {
    await Supabase.initialize(url: url, anonKey: anonKey);
  }

  static SupabaseClient get client => Supabase.instance.client;
}
