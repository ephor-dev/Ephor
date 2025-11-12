import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase service for handling authentication and database connections
class SupabaseService {
  static SupabaseClient? _client;
  
  /// Initialize Supabase with your project URL and anon key
  /// Replace these with your actual Supabase project credentials
  static Future<void> initialize({
    required String supabaseUrl,
    required String supabaseAnonKey,
  }) async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
    _client = Supabase.instance.client;
  }

  /// Get the Supabase client instance
  static SupabaseClient get client {
    if (_client == null) {
      throw Exception(
        'Supabase not initialized. Call SupabaseService.initialize() first.',
      );
    }
    return _client!;
  }

  /// Get the Supabase auth instance
  static GoTrueClient get auth => client.auth;

  /// Get a specific table from the database
  static SupabaseQueryBuilder table(String tableName) {
    return client.from(tableName);
  }

  /// Check if user is authenticated
  static bool get isAuthenticated => auth.currentUser != null;

  /// Get current user
  static User? get currentUser => auth.currentUser;

  /// Sign out current user
  static Future<void> signOut() async {
    await auth.signOut();
  }
}

