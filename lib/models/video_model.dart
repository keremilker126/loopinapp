class VideoModel {
  final int id;
  final String baslik;
  final String videoUrl;
  final String kapakResmiUrl;
  final String aciklama;
  final DateTime yuklenmeTarihi;
  final int izlenmeSayisi;
  final int likeSayisi;
  final int kullaniciId;
  final String kullaniciAdi;
  final int aboneSayisi; // 🔥 Yeni eklenen alan

  VideoModel({
    required this.id,
    required this.baslik,
    required this.videoUrl,
    required this.kapakResmiUrl,
    required this.aciklama,
    required this.yuklenmeTarihi,
    required this.izlenmeSayisi,
    required this.likeSayisi,
    required this.kullaniciId,
    required this.kullaniciAdi,
    required this.aboneSayisi,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id'] ?? 0,
      baslik: json['baslik'] ?? '',
      videoUrl: json['videoUrl'] ?? '',
      kapakResmiUrl: json['kapakResmiUrl'] ?? '',
      aciklama: json['aciklama'] ?? '',
      yuklenmeTarihi: json['yuklenmeTarihi'] != null 
          ? DateTime.parse(json['yuklenmeTarihi']) 
          : DateTime.now(),
      izlenmeSayisi: json['izlenmeSayisi'] ?? 0,
      likeSayisi: json['likeSayisi'] ?? 0,
      kullaniciId: json['kullaniciId'] ?? 0,
      kullaniciAdi: json['kullaniciAdi'] ?? 'Bilinmeyen Kullanıcı',
      aboneSayisi: json['aboneSayisi'] ?? 0, // 🔥 JSON'dan çekiyoruz
    );
  }
}