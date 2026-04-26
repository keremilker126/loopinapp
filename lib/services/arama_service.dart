import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/search_result.dart';

class AramaService {
  // 🔥 Mobilde localhost yerine LAN IP kullan
  final String baseUrl = "http://10.0.2.2:5144/api/AramaApi"; 
  // kendi bilgisayar IP adresini yaz

  Future<SearchResult> search(String query) async {
    try {
      final response = await http.get(Uri.parse("$baseUrl?q=$query"));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return SearchResult.fromJson(data);
      } else {
        throw Exception("Arama hatası: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Bağlantı hatası: $e");
    }
  }
}
