import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/begenme_model.dart';
import '../models/video_model.dart';

class BegenmeService {
  // 🔥 Mobilde localhost yerine LAN IP kullan
  final String baseUrl = "http://10.0.2.2:5144/api/BegenmeApi"; 
  // kendi bilgisayar IP adresini yaz

  // Beğeni Durumunu Kontrol Et
  Future<bool> checkLikeStatus(int kullaniciId, int videoId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/check?kullaniciId=$kullaniciId&videoId=$videoId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is bool) return data;
        return data['isLiked'] ?? false;
      }
      return false;
    } catch (e) {
      print("Beğeni durumu kontrol hatası: $e");
      return false;
    }
  }

  // Beğenme / Beğeniyi Geri Alma (Toggle)
  Future<Map<String, dynamic>?> toggleLike(BegenmeModel model) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/toggle'),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(model.toJson()),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("Beğenme Hatası: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("Beğenme Servis Hatası: $e");
      return null;
    }
  }

  // Kullanıcının Beğendiği Videoları Getir
  Future<List<VideoModel>> getLikedVideos(int userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/user/$userId'));

      if (response.statusCode == 200) {
        List jsonResponse = jsonDecode(response.body);
        return jsonResponse.map((v) => VideoModel.fromJson(v)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print("Beğenilen videolar yüklenirken hata: $e");
      return [];
    }
  }

  // Beğeniyi Kaldır
  Future<bool> removeLike(int kullaniciId, int videoId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/remove'),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "kullaniciId": kullaniciId,
          "videoId": videoId,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print("Kaldırma Hatası: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Beğeni kaldırma servis hatası: $e");
      return false;
    }
  }
}
