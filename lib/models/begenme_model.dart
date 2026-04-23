class BegenmeModel {
  final int kullaniciId;
  final int videoId;

  BegenmeModel({
    required this.kullaniciId,
    required this.videoId,
  });

  Map<String, dynamic> toJson() {
    return {
      "kullaniciId": kullaniciId, // C# tarafındaki CamelCase ayarına uygun
      "videoId": videoId,
    };
  }

  factory BegenmeModel.fromJson(Map<String, dynamic> json) {
    return BegenmeModel(
      kullaniciId: json['kullaniciId'] ?? 0,
      videoId: json['videoId'] ?? 0,
    );
  }
}