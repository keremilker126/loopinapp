class YorumModel {
  final int id;
  final String icerik;
  final DateTime tarih;
  final int kullaniciId;
  final String kullaniciAdi;
  final int videoId;

  YorumModel({
    required this.id,
    required this.icerik,
    required this.tarih,
    required this.kullaniciId,
    required this.kullaniciAdi,
    required this.videoId,
  });

  factory YorumModel.fromJson(Map<String, dynamic> json) {
    return YorumModel(
      id: json['id'] ?? 0,
      icerik: json['icerik'] ?? '',
      tarih: DateTime.parse(json['tarih']),
      kullaniciId: json['kullaniciId'] ?? 0,
      kullaniciAdi: json['kullaniciAdi'] ?? 'Bilinmeyen',
      videoId: json['videoId'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "icerik": icerik,
      "tarih": tarih.toIso8601String(),
      "kullaniciId": kullaniciId,
      "kullaniciAdi": kullaniciAdi,
      "videoId": videoId,
    };
  }
}
