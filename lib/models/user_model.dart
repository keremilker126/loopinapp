class UserModel {
  final int id;
  final String kullaniciAdi;
  final String email;
  final bool emailOnayli;
  final int aboneSayisi; // 🔥 Yeni eklendi

  UserModel({
    required this.id, 
    required this.kullaniciAdi, 
    required this.email, 
    required this.emailOnayli,
    this.aboneSayisi = 0, // 🔥 Varsayılan değer
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      kullaniciAdi: json['kullaniciAdi'] ?? '',
      email: json['email'] ?? '',
      emailOnayli: json['emailOnayli'] ?? false,
      aboneSayisi: json['aboneSayisi'] ?? 0, // 🔥 Backend DTO'dan gelen veri
    );
  }
}