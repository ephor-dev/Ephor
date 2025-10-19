import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // 1. Import the package
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

  if (supabaseUrl == null || supabaseAnonKey == null) {
    throw Exception("Supabase URL and Anon Key are required in .env file.");
  }

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
    authOptions: FlutterAuthClientOptions(
      localStorage: EmptyLocalStorage()
    )
  );

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;