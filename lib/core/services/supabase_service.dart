import 'package:supabase_flutter/supabase_flutter.dart';

/// Thin wrapper around Supabase initialization and the shared client.
///
/// The anon key is a public, client-side key: it is safe to ship in the app
/// because access is enforced by Row Level Security (see supabase_schema.sql).
class SupabaseService {
  SupabaseService._();

  static const String url = 'https://agjmzujptenllpqpkffv.supabase.co';
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFnam16dWpwdGVubGxwcXBrZmZ2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTQzMjA3NDIsImV4cCI6MjEwOTg5Njc0Mn0.LG1qTX4JoJNCQJEfJoOrqID2JO8THyTbJBvAA7XHP-0';

  static Future<void> init() async {
    await Supabase.initialize(url: url, anonKey: anonKey);
  }

  static SupabaseClient get client => Supabase.instance.client;
}
