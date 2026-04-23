class AbonelikModel {
  final int aboneOlanId;
  final int aboneOlunanId;

  AbonelikModel({
    required this.aboneOlanId,
    required this.aboneOlunanId,
  });

// lib/models/abonelik_model.dart içinde değiştir:
Map<String, dynamic> toJson() {
  return {
    "aboneOlanId": aboneOlanId,   // Baş harfi küçük yap
    "aboneOlunanId": aboneOlunanId, // Baş harfi küçük yap
  };
}

  factory AbonelikModel.fromJson(Map<String, dynamic> json) {
    return AbonelikModel(
      aboneOlanId: json['aboneOlanId'] ?? 0,
      aboneOlunanId: json['aboneOlunanId'] ?? 0,
    );
  }
}