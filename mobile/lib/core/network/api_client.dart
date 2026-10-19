import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  final http.Client client;

  ApiClient({http.Client? client}) : client = client ?? http.Client();

  Future<Map<String, dynamic>> get(String endpoint) async {
    final response = await client.get(
      Uri.parse(endpoint),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('HTTP GET Error ${response.statusCode}: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body) async {
    final response = await client.post(
      Uri.parse(endpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('HTTP POST Error ${response.statusCode}: ${response.body}');
    }
  }
}
