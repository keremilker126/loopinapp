import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/abonelik_model.dart';

class AbonelikService {
  // 🔥 Mobilde localhost yerine LAN IP kullan
  final String baseUrl = "http://10.0.2.2:5144/api/AbonelikApi"; 
  // kendi bilgisayar IP adresini yaz

  // Abonelik Durumu ve Sayısını Kontrol Et (Sayfa açılışında)
  Future<Map<String, dynamic>> checkSubscriptionStatus(
    int followerId,
    int followingId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/check?followerId=$followerId&followingId=$followingId'),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body); 
        // {isSubscribed: bool, subscriberCount: int}
      }
    } catch (e) {
      print("Abonelik kontrol hatası: $e");
    }
    return {'isSubscribed': false, 'subscriberCount': 0};
  }

  // Abone Ol / Çık (Toggle)
  Future<Map<String, dynamic>?> toggleSubscription(AbonelikModel model) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/toggle'),
        headers: {"Content-Type": "application/json"},
        body: json.encode(model.toJson()),
      );

      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print("BAĞLANTI HATASI DETAYI: $e");
    }
    return null;
  }

  // Abone olunan kullanıcıları getir
  Future<List<Map<String, dynamic>>> getFollowing(int userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/following/$userId'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      print("Takip edilenleri getirme hatası: $e");
    }
    return [];
  }
}
