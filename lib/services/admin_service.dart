import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class AdminService {
  String get apiBaseUrl {
    if (kIsWeb) {
      final scheme = Uri.base.scheme.isEmpty ? 'http' : Uri.base.scheme;
      final host = Uri.base.host.isEmpty ? 'localhost' : Uri.base.host;
      return '$scheme://$host:5144';
    }
    return 'http://localhost:5144';
  }

  String get baseUrl => '$apiBaseUrl/api/auth';

  // 🔥 KULLANICI SİL
  Future<bool> deleteUser(int id, String adminEmail) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/admin/delete-user/$id?adminEmail=$adminEmail"),
    );

    return response.statusCode == 200;
  }

  // 🔥 VİDEO SİL
  Future<bool> deleteVideo(int id, String adminEmail) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/admin/delete-video/$id?adminEmail=$adminEmail"),
    );

    return response.statusCode == 200;
  }

  // 🔥 EMAİL ENGELLE

  // ✅ YENİ: ENGEL KALDIR
 // ✅ ENGEL KALDIR (Düzeltilmiş Versiyon)
Future<bool> unblockEmail(String email, String adminEmail) async {
  try {
    // API Query string üzerinden beklediği için parametreleri URL'ye ekliyoruz
    final response = await http.post(
      Uri.parse("$baseUrl/admin/unblock-email?email=$email&adminEmail=$adminEmail"),
    );

    return response.statusCode == 200;
  } catch (e) {
    print("Engel kaldırma hatası: $e");
    return false;
  }
}
  

  // ✅ TÜM KULLANICILARI GETİR (Admin email ile)
  Future<List<UserModel>> getAllUsers(String adminEmail) async {
    final response = await http.get(
      Uri.parse("$baseUrl/admin/users?adminEmail=$adminEmail"),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as List<dynamic>;
      return body
          .map((item) => UserModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      return [];
    }
  }

  // ✅ YENİ: EMAİL ENGELLE

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

  // 📌 2. Yasaklı e-postaların listesini getir
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

  // ✅ YENİ: ENGELLİ EMAİLLERİ GETİR
}
