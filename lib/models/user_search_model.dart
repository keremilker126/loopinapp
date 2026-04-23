class UserSearchModel {
  final int id;
  final String kullaniciAdi;
  final String email;
  final bool emailOnayli;

  UserSearchModel({
    required this.id,
    required this.kullaniciAdi,
    required this.email,
    required this.emailOnayli,
  });

  factory UserSearchModel.fromJson(Map<String, dynamic> json) {
    return UserSearchModel(
      id: json['id'],
      kullaniciAdi: json['kullaniciAdi'],
      email: json['email'],
      emailOnayli: json['emailOnayli'],
    );
  }
}
