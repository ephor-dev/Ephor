import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ModelAPIService {
  static const String _baseUrl = 'https://catna-ai-model-pi.vercel.app';
  final http.Client _client;

  ModelAPIService({http.Client? client}) : _client = client ?? http.Client();

  /// Uploads binary Excel data to the analysis endpoint
  Future<http.Response> analyzeDatasetBytes(List<int> fileBytes, String filename) async {
    final uri = Uri.parse('$_baseUrl/analyze/');
    
    var request = http.MultipartRequest('POST', uri);
    
    // Add the file from memory bytes
    request.files.add(http.MultipartFile.fromBytes(
      'file', 
      fileBytes,
      filename: filename, // The API likely checks the .xlsx extension
      contentType: MediaType('application', 'vnd.openxmlformats-officedocument.spreadsheetml.sheet'),
    ));

    try {
      final streamedResponse = await _client.send(request);
      return await http.Response.fromStream(streamedResponse);
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }
}