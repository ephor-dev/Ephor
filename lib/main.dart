import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import 'package:ephor/ui/Dashboard/widgets/widgets.dart'; 
import 'package:ephor/ui/Dashboard/view_model/view_models.dart';

void main() {
  runApp(
    // 3. Wrap the app with ChangeNotifierProvider
    ChangeNotifierProvider(
      create: (context) => UserProfileViewModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryRed = Color(0xFFD32F2F); 
    
    return MaterialApp(
      title: 'EPHOR Dashboard',
      debugShowCheckedModeBanner: false, 

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: primaryRed),
        useMaterial3: true,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontFamily: 'Inter'), 
        ),
        scaffoldBackgroundColor: Colors.grey.shade50, 
      ),
      
      // 4. The 'Widgets' screen is now the entry point that consumes the ViewModel
      home: const Widgets(), // 'const' is fine here since Widgets is a const constructor
    );
  }
}