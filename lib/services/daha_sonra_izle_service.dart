import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:loopin/models/daha_sonra_izle_model.dart';
import '../models/video_model.dart';

class DahaSonraIzleService {
  // 🔥 Mobilde localhost yerine LAN IP kullan
  final String baseUrl = "http://10.0.2.2:5144/api/DahaSonraIzleApi"; 
  // kendi bilgisayar IP adresini yaz

  // Kullanıcının Daha Sonra İzle listesini getir
  Future<List<VideoModel>> getList(int userId) async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/$userId"));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => VideoModel.fromJson(e)).toList();
      } else {
        throw Exception("Liste alınamadı: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Bağlantı hatası: $e");
    }
  }

  // Listeye ekle / çıkar (toggle)
  Future<String> toggle(DahaSonraIzleDto dto) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/toggle"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(dto.toJson()),
      );
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        return result['status'];
      } else {
        throw Exception("Toggle işlemi başarısız: ${response.body}");
      }
    } catch (e) {
      throw Exception("Bağlantı hatası: $e");
    }
  }

  // Tek bir videoyu listeden kaldır
  Future<void> remove(DahaSonraIzleDto dto) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/${dto.kullaniciId}/${dto.videoId}"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(dto.toJson()),
      );
      if (response.statusCode != 200) {
        throw Exception("Silme işlemi başarısız: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Bağlantı hatası: $e");
    }
  }

  // Tüm listeyi temizle
  Future<void> clearAll(int userId) async {
    try {
      final response = await http.delete(Uri.parse("$baseUrl/clear/$userId"));
      if (response.statusCode != 200) {
        throw Exception("Liste temizlenemedi: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Bağlantı hatası: $e");
    }
  }
}
