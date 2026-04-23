class VideoSearchModel {
  final int id;
  final String baslik;
  final String videoUrl;
  final String kapakResmiUrl;
  final String aciklama;
  final String yuklenmeTarihi;
  final int izlenmeSayisi;
  final int likeSayisi;
  final int kullaniciId;
  final String kullaniciAdi;
  final int aboneSayisi;


  VideoSearchModel({
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

  factory VideoSearchModel.fromJson(Map<String, dynamic> json) {
    return VideoSearchModel(
      id: json['id'],
      baslik: json['baslik'],
      videoUrl: json['videoUrl'],
      kapakResmiUrl: json['kapakResmiUrl'],
      aciklama: json['aciklama'] ?? '',
      yuklenmeTarihi: json['yuklenmeTarihi'] ?? '',
      izlenmeSayisi: json['izlenmeSayisi'],
      likeSayisi: json['likeSayisi'],
      kullaniciId: json['kullaniciId'],
      kullaniciAdi: json['kullaniciAdi'],
      aboneSayisi: json['aboneSayisi'],

    );
  }
}
