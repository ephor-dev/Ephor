import 'package:flutter/material.dart';
import 'package:ephor/ui/Dashboard/widgets/widgets.dart'; // This import should be fine for widgets used in the Dashboard UI.
// You might need a more specific import if your Dashboard is a separate view, 
// but we will reuse the existing path for now.

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // The application's primary theme configuration
  @override
  Widget build(BuildContext context) {
    // Define a primary color based on the red from your logo
    // FIX: primaryRed definition moved here to ensure correct scoping.
    const Color primaryRed = Color(0xFFD32F2F); 
    
    return MaterialApp(
      title: 'EPHOR Dashboard',
      debugShowCheckedModeBanner: false, // Turn off the debug banner

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: primaryRed),
        useMaterial3: true,
        // Customize text style for the entire app body
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontFamily: 'Inter'), // Use Inter font if available
        ),
        // Ensure that the background matches the light gray tone in your design
        scaffoldBackgroundColor: Colors.grey.shade50, 
      ),
      
      // Set your DashboardWidget as the default screen
      // FIX: Removed 'const' keyword to resolve the "Not a constant expression" error.
      home: Widgets(), 
    );
  }
}
