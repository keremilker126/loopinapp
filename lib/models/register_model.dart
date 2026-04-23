class RegisterModel {
  final String kullaniciAdi;
  final String email;
  final String sifre;

  RegisterModel({
    required this.kullaniciAdi, 
    required this.email, 
    required this.sifre
  });

  Map<String, dynamic> toJson() {
    return {
      "kullaniciAdi": kullaniciAdi,
      "email": email,
      "sifre": sifre,
    };
  }
}