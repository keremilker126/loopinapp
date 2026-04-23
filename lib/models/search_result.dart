import 'video_search_model.dart';
import 'user_search_model.dart';

class SearchResult {
  final String query;
  final int videoCount;
  final int userCount;
  final List<VideoSearchModel> videolar;
  final List<UserSearchModel> kullanicilar;
  final List<int> abonelikler;

  SearchResult({
    required this.query,
    required this.videoCount,
    required this.userCount,
    required this.videolar,
    required this.kullanicilar,
    required this.abonelikler,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    final videoList = (json['videolar'] as List)
        .map((v) => VideoSearchModel.fromJson(v))
        .toList();

    final userList = (json['kullanicilar'] as List)
        .map((u) => UserSearchModel.fromJson(u))
        .toList();

    final abonelikList = (json['abonelikler'] as List?)?.map((a) => a as int).toList() ?? [];

    return SearchResult(
      query: json['query'],
      videoCount: json['videoCount'],
      userCount: json['userCount'],
      videolar: videoList,
      kullanicilar: userList,
      abonelikler: abonelikList,
    );
  }
}
