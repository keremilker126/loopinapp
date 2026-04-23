class DahaSonraIzleDto {
  final int kullaniciId;
  final int videoId;

  DahaSonraIzleDto({required this.kullaniciId, required this.videoId});

  Map<String, dynamic> toJson() => {
        'kullaniciId': kullaniciId,
        'videoId': videoId,
      };
}