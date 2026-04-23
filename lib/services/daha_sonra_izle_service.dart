import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:loopin/models/daha_sonra_izle_model.dart';
import '../models/video_model.dart';

class DahaSonraIzleService {
  final String baseUrl = "http://localhost:5144/api/DahaSonraIzleApi";

  Future<List<VideoModel>> getList(int userId) async {
    final response = await http.get(Uri.parse("$baseUrl/$userId"));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => VideoModel.fromJson(e)).toList();
    } else {
      throw Exception("Liste alınamadı");
    }
  }

  Future<String> toggle(DahaSonraIzleDto dto) async {
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
}


  Future<void> remove(DahaSonraIzleDto dto) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/${dto.kullaniciId}/${dto.videoId}"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(dto.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception("Silme işlemi başarısız");
    }
  }

  Future<void> clearAll(int userId) async {
    final response = await http.delete(Uri.parse("$baseUrl/clear/$userId"));
    if (response.statusCode != 200) {
      throw Exception("Liste temizlenemedi");
    }
  }
}
