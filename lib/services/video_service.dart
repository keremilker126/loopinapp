import 'dart:async';
import 'dart:convert';
import 'dart:io'; // 🔥 Mobilde dosya işlemleri için
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../models/video_model.dart';
import 'package:http_parser/http_parser.dart';

class VideoService {
  // 🔥 Mobilde localhost yerine LAN IP kullan
  final String apiBaseUrl = "http://10.0.2.2:5144"; // kendi bilgisayar IP adresini yaz

  String get baseUrl => '$apiBaseUrl/api/VideoApi';

  Future<List<VideoModel>> tumVideolariGetir() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((dynamic item) => VideoModel.fromJson(item)).toList();
      } else {
        throw 'Videolar yüklenemedi (${response.statusCode}).';
      }
    } catch (e) {
      throw 'Hata: $e';
    }
  }

  String kapakResmiUrlAl(String urlPath) {
    if (urlPath.isEmpty) return '';
    if (urlPath.startsWith('http')) return urlPath;
    return '$apiBaseUrl$urlPath';
  }

  Future<int?> izlenmeArtir(int videoId, {int? userId}) async {
    try {
      final uri = Uri.parse(
        '$baseUrl/$videoId/izlenme${userId != null ? "?userId=$userId" : ""}',
      );
      final response = await http.post(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['yeniIzlenmeSayisi'] as int;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  MediaType _getMediaType(String path) {
    String extension = path.split('.').last.toLowerCase();
    switch (extension) {
      case 'mp4':
        return MediaType('video', 'mp4');
      case 'mov':
        return MediaType('video', 'quicktime');
      case 'avi':
        return MediaType('video', 'avi');
      case 'mkv':
        return MediaType('video', 'x-matroska');
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'png':
        return MediaType('image', 'png');
      case 'gif':
        return MediaType('image', 'gif');
      default:
        return MediaType('application', 'octet-stream');
    }
  }

  // 🔥 Mobilde dosya yükleme için fromPath kullanıyoruz
  Future<String?> videoYukle({
    required XFile videoFile,
    required XFile imageFile,
    required String baslik,
    required String aciklama,
    required int kullaniciId,
  }) async {
    var client = http.Client();
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/upload'));

      request.fields['baslik'] = baslik;
      request.fields['aciklama'] = aciklama;
      request.fields['kullaniciId'] = kullaniciId.toString();

      request.files.add(
        await http.MultipartFile.fromPath(
          'videoDosyasi',
          videoFile.path,
          contentType: _getMediaType(videoFile.path),
        ),
      );

      request.files.add(
        await http.MultipartFile.fromPath(
          'kapakResmi',
          imageFile.path,
          contentType: _getMediaType(imageFile.path),
        ),
      );

      var streamedResponse = await client.send(request);
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return null; // Başarılı
      } else {
        return "Sunucu Hatası (${response.statusCode}): ${response.body}";
      }
    } catch (e) {
      return "Bağlantı hatası: $e";
    } finally {
      client.close();
    }
  }

  Future<List<VideoModel>> trendVideolariGetir() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/trends'));
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((dynamic item) => VideoModel.fromJson(item)).toList();
      } else {
        throw 'Trend videolar yüklenemedi (${response.statusCode}).';
      }
    } catch (e) {
      throw 'Hata: $e';
    }
  }

  Future<List<VideoModel>> kullaniciVideolariniGetir(int userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/user/$userId'));
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((dynamic item) => VideoModel.fromJson(item)).toList();
      } else {
        throw 'Videolarınız getirilemedi (${response.statusCode})';
      }
    } catch (e) {
      throw 'Hata: $e';
    }
  }

  Future<bool> videoSil(int videoId) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$videoId'));
      return response.statusCode == 200;
    } catch (e) {
      throw 'Hata: $e';
    }
  }

  Future<VideoModel> videoDetayiGetir(int videoId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$videoId'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return VideoModel.fromJson(data);
      } else {
        throw 'Video getirilemedi (${response.statusCode})';
      }
    } catch (e) {
      throw 'Hata: $e';
    }
  }

  Future<VideoModel> getVideoById(int videoId) async {
    final response = await http.get(
      Uri.parse("$apiBaseUrl/api/GecmisApi/video/$videoId"),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return VideoModel.fromJson(data);
    } else {
      throw Exception("Video bulunamadı: ${response.statusCode}");
    }
  }
}
