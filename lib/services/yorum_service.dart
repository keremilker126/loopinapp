import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/yorum_model.dart';
import 'package:flutter/foundation.dart';

class YorumService {
  String get apiBaseUrl {
    if (kIsWeb) {
      final scheme = Uri.base.scheme.isEmpty ? 'http' : Uri.base.scheme;
      final host = Uri.base.host.isEmpty ? 'localhost' : Uri.base.host;
      return '$scheme://$host:5144';
    }
    return 'http://localhost:5144';
  }

  String get baseUrl => '$apiBaseUrl/api/YorumApi';

  Future<List<YorumModel>> yorumlariGetir(int videoId) async {
    final response = await http.get(Uri.parse('$baseUrl/video/$videoId'));
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => YorumModel.fromJson(item)).toList();
    } else {
      throw Exception("Yorumlar yüklenemedi");
    }
  }

  Future<bool> yorumEkle(YorumModel yorum) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(yorum.toJson()),
    );
    return response.statusCode == 200;
  }

  Future<bool> yorumSil(int yorumId, int userId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$yorumId?userId=$userId'),
    );
    return response.statusCode == 200;
  }
}
