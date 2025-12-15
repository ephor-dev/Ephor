import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ephor/utils/custom_message_exception.dart'; // Ensure this import exists

class ModelAPIService {
  // Your Vercel Function URL
  static const String _baseUrl = 'https://ai-model-tau-six.vercel.app/api'; 
  final http.Client _client;

  ModelAPIService({http.Client? client}) : _client = client ?? http.Client();

  /// Sends calculated stats to Vercel/Groq for insights
  Future<Map<String, dynamic>> getAiInsights({
    required Map<String, dynamic> summaryStats,
    required bool hasImpact
  }) async {
    final uri = Uri.parse('$_baseUrl/analyze'); // Maps to api/analyze.js
    
    try {
      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "summaryStats": summaryStats,
          "hasImpact": hasImpact
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        // Handle Vercel or Groq errors
        throw CustomMessageException('AI Service Error: ${response.body}');
      }
    } catch (e) {
      throw CustomMessageException('Connection error: $e');
    }
  }
}