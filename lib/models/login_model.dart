class LoginModel {
  final String email;
  final String sifre;

  LoginModel({required this.email, required this.sifre});

  // API'ye JSON formatında göndermek için
  Map<String, dynamic> toJson() {
    return {
      "email": email,
      "sifre": sifre,
    };
  }
}