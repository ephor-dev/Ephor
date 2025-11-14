import 'package:ephor/data/services/supabase/supabase_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  // static const String supabaseUrl = 'https://qkvsddnqbsodaukycoaz.supabase.co';
  // static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFrdnNkZG5xYnNvZGF1a3ljb2F6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjIwMDYyMjMsImV4cCI6MjA3NzU4MjIyM30.8E8ORA1yEZB2s3OjGWqvMoKiYme1fuWwcELL06niigQ';
  
  static final String supabaseUrl = dotenv.env['SUPABASE_URL']!;
  static final String supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY']!;

  static Future<void> initialize() async {
    await SupabaseService.initialize(
      supabaseUrl: supabaseUrl,
      supabaseAnonKey: supabaseAnonKey,
    );
  }
}
