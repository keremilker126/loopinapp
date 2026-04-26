import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/yorum_model.dart';

class YorumService {
  // 🔥 Mobilde localhost yerine LAN IP kullan
  final String apiBaseUrl = "http://10.0.2.2:5144"; // kendi bilgisayar IP adresini yaz

  String get baseUrl => '$apiBaseUrl/api/YorumApi';

  // Yorumları getir
  Future<List<YorumModel>> yorumlariGetir(int videoId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/video/$videoId'));
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => YorumModel.fromJson(item)).toList();
      } else {
        throw Exception("Yorumlar yüklenemedi (${response.statusCode})");
      }
    } catch (e) {
      throw Exception("Bağlantı hatası: $e");
    }
  }

  // Yorum ekle
  Future<bool> yorumEkle(YorumModel yorum) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(yorum.toJson()),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Yorum ekleme hatası: $e");
      return false;
    }
  }

  // Yorum sil
  Future<bool> yorumSil(int yorumId, int userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$yorumId?userId=$userId'),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Yorum silme hatası: $e");
      return false;
    }
  }
}
