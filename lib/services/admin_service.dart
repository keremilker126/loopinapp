import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class AdminService {
  // 🔥 Mobilde localhost yerine LAN IP kullan
  final String apiBaseUrl = "http://10.0.2.2:5144"; // kendi bilgisayar IP adresini yaz

  String get baseUrl => '$apiBaseUrl/api/auth';

  // 🔥 KULLANICI SİL
  Future<bool> deleteUser(int id, String adminEmail) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/admin/delete-user/$id?adminEmail=$adminEmail"),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Kullanıcı silme hatası: $e");
      return false;
    }
  }

  // 🔥 VİDEO SİL
  Future<bool> deleteVideo(int id, String adminEmail) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/admin/delete-video/$id?adminEmail=$adminEmail"),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Video silme hatası: $e");
      return false;
    }
  }

  // ✅ ENGEL KALDIR
  Future<bool> unblockEmail(String email, String adminEmail) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/admin/unblock-email?email=$email&adminEmail=$adminEmail"),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Engel kaldırma hatası: $e");
      return false;
    }
  }

  // ✅ TÜM KULLANICILARI GETİR
  Future<List<UserModel>> getAllUsers(String adminEmail) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/admin/users?adminEmail=$adminEmail"),
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as List<dynamic>;
        return body.map((item) => UserModel.fromJson(item)).toList();
      }
    } catch (e) {
      print("Kullanıcı listesi hatası: $e");
    }
    return [];
  }

  // ✅ EMAİL ENGELLE
  Future<Map<String, dynamic>> blockEmail(String targetEmail, String adminEmail) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/admin/block-email?email=$targetEmail&adminEmail=$adminEmail"),
      );
      final data = jsonDecode(response.body);
      return {
        "success": response.statusCode == 200,
        "message": data['message'] ?? "İşlem başarısız",
      };
    } catch (e) {
      return {"success": false, "message": "Bağlantı hatası: $e"};
    }
  }

  // ✅ ENGELLİ EMAİLLERİ GETİR
  Future<List<String>> getBlockedEmails(String adminEmail) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/admin/blocked-emails?adminEmail=$adminEmail"),
      );
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.cast<String>();
      }
    } catch (e) {
      print("Yasaklı liste getirme hatası: $e");
    }
    return [];
  }
}
