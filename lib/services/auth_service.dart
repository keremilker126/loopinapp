import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/login_model.dart';
import '../models/register_model.dart';
import '../models/user_model.dart';

class AuthService {
  // 🔥 Mobilde localhost yerine LAN IP kullan
  final String apiBaseUrl = "http://10.0.2.2:5144"; // kendi bilgisayar IP adresini yaz

  String get baseUrl => '$apiBaseUrl/api/auth';

  Future<Map<String, dynamic>> register(RegisterModel model) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(model.toJson()),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"message": "Sunucu hatası!"};
    }
  }

  Future<Map<String, dynamic>> login(LoginModel model) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(model.toJson()),
      );
      final data = jsonDecode(response.body);
      UserModel? user;
      if (data['user'] != null && data['user'] is Map<String, dynamic>) {
        user = UserModel.fromJson(data['user']);
      }
      return {
        "success": response.statusCode == 200,
        "requiresVerification": data['requiresVerification'] ?? false,
        "message": data['message'] ?? "Hata oluştu",
        "user": user,
      };
    } catch (e) {
      return {"success": false, "message": "Bağlantı kesildi!"};
    }
  }

  Future<UserModel?> verifyLogin(String token) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/verify-login?token=$token"),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserModel.fromJson(data['user']);
      }
    } catch (e) {
      print("Doğrulama hatası: $e");
    }
    return null;
  }

  Future<Map<String, dynamic>> forgotPasswordStep1(String email) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/forgot-password"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
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

  Future<Map<String, dynamic>> forgotPasswordStep2(
    String email,
    String code,
    String newPassword,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/reset-password"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "code": code,
          "newPassword": newPassword,
        }),
      );
      final data = jsonDecode(response.body);
      return {
        "success": response.statusCode == 200,
        "message": data['message'] ?? "Güncelleme başarısız",
      };
    } catch (e) {
      return {"success": false, "message": "Bağlantı hatası: $e"};
    }
  }

  Future<Map<String, dynamic>> changePassword(
    String email,
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/change-password"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "currentPassword": currentPassword,
          "newPassword": newPassword,
        }),
      );
      final data = jsonDecode(response.body);
      return {
        "success": response.statusCode == 200,
        "message": data['message'] ?? "Bir hata oluştu",
      };
    } catch (e) {
      return {"success": false, "message": "Bağlantı hatası: $e"};
    }
  }

  Future<UserModel> getUserById(int id) async {
    final response = await http.get(Uri.parse("$baseUrl/user/$id"));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return UserModel.fromJson(data);
    } else {
      throw Exception("Kullanıcı bulunamadı: ${response.statusCode}");
    }
  }
}
