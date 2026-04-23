import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../models/video_model.dart';
import 'package:http_parser/http_parser.dart';

class VideoService {
  String get apiBaseUrl {
    if (kIsWeb) {
      final scheme = Uri.base.scheme.isEmpty ? 'http' : Uri.base.scheme;
      final host = Uri.base.host.isEmpty ? 'localhost' : Uri.base.host;
      return '$scheme://$host:5144';
    }
    return 'http://localhost:5144';
  }

  String get baseUrl => '$apiBaseUrl/api/VideoApi';

  Future<List<VideoModel>> tumVideolariGetir() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((dynamic item) => VideoModel.fromJson(item)).toList();
      } else {
        throw 'Videolar yüklenemedi.';
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

  Future<String?> videoYukle({
    required XFile videoFile,
    required XFile imageFile,
    required String baslik,
    required String aciklama,
    required int kullaniciId,
  }) async {
    var client = http.Client(); // Bağlantıyı manuel yönetmek için
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/upload'));

      request.fields['baslik'] = baslik;
      request.fields['aciklama'] = aciklama;
      request.fields['kullaniciId'] = kullaniciId.toString();

      // 🔥 WEB İÇİN KRİTİK: Byte olarak okuma
      final videoBytes = await videoFile.readAsBytes();
      final imageBytes = await imageFile.readAsBytes();

      request.files.add(
        http.MultipartFile.fromBytes(
          'videoDosyası',
          videoBytes,
          filename: videoFile.name,
          contentType: _getMediaType(videoFile.name),
        ),
      );

      request.files.add(
        http.MultipartFile.fromBytes(
          'kapakResmi',
          imageBytes,
          filename: imageFile.name,
          contentType: _getMediaType(imageFile.name),
        ),
      );

      // Gönderim ve Cevap Bekleme
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
      client.close(); // İşlem bitince soketi serbest bırak
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
  // VideoService sınıfının içine ekleyin:

  Future<List<VideoModel>> kullaniciVideolariniGetir(int userId) async {
    try {
      // Backend'deki [HttpGet("user/{userId}")] endpoint'ine istek atar
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
      if (response.statusCode == 200) {
        return true;
      } else {
        throw 'Video silinemedi (${response.statusCode})';
      }
    } catch (e) {
      throw 'Hata: $e';
    }
  }

  // Video ID'sine göre tek bir video getir (Detaylı bilgiler ile)
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
  final response = await http.get(Uri.parse("http://localhost:5144/api/GecmisApi/video/$videoId"));

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
    return VideoModel.fromJson(data);
  } else {
    throw Exception("Video bulunamadı: ${response.statusCode}");
  }
}

}
