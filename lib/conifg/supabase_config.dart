import 'package:ephor/data/services/supabase_service.dart';

/// Configuration file for Supabase initialization
/// 
/// SETUP INSTRUCTIONS:
/// 1. Go to https://supabase.com and create a project (or use existing)
/// 2. In your Supabase project dashboard, go to Settings -> API
/// 3. Copy the "Project URL" and paste it below as supabaseUrl
/// 4. Copy the "anon/public" key and paste it below as supabaseAnonKey
/// 5. Save this file
/// 
/// Example:
///   supabaseUrl = 'https://xxxxxxxxxxxxx.supabase.co'
///   supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'


class SupabaseConfig {
  // TODO: Replace with your Supabase project URL
  // Format: https://your-project-ref.supabase.co
  static const String supabaseUrl = 'https://qkvsddnqbsodaukycoaz.supabase.co';

  // TODO: Replace with your Supabase anon/public key
  // This is safe to expose in client-side apps (it's public)
  // Format: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFrdnNkZG5xYnNvZGF1a3ljb2F6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjIwMDYyMjMsImV4cCI6MjA3NzU4MjIyM30.8E8ORA1yEZB2s3OjGWqvMoKiYme1fuWwcELL06niigQ';

  /// Initialize Supabase service
  /// Call this in main() before runApp()
  static Future<void> initialize() async {
    await SupabaseService.initialize(
      supabaseUrl: supabaseUrl,
      supabaseAnonKey: supabaseAnonKey,
    );
  }
}

