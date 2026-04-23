import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/search_result.dart';

class AramaService {
  final String baseUrl = "http://localhost:5144/api/AramaApi";

  Future<SearchResult> search(String query) async {
    final response = await http.get(Uri.parse("$baseUrl?q=$query"));

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return SearchResult.fromJson(data);
    } else {
      throw Exception("Arama hatası: ${response.statusCode}");
    }
  }
}
