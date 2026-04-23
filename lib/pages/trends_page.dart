import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/video_model.dart';
import '../services/video_service.dart';
import 'izle_page.dart'; // İzle sayfası import edildi

class TrendsPage extends StatefulWidget {
  final UserModel? currentUser; // Kullanıcı bilgisi eklendi

  const TrendsPage({Key? key, this.currentUser}) : super(key: key);

  @override
  State<TrendsPage> createState() => _TrendsPageState();
}

class _TrendsPageState extends State<TrendsPage> {
  final VideoService _videoService = VideoService();
  late Future<List<VideoModel>> _trendVideos;

  // HomePage ile uyumlu renkler
  final Color bgColor = const Color(0xFF0F0F14);
  final Color cardColor = const Color(0xFF1A1A22);
  final Color purpleColor = const Color(0xFF5E5CE6);

  @override
  void initState() {
    super.initState();
    _trendVideos = _videoService.trendVideolariGetir();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        iconTheme: IconThemeData(color: purpleColor),
        title: Row(
          children: [
            Icon(Icons.whatshot, color: purpleColor),
            const SizedBox(width: 8),
            const Text(
              "Popüler Trendler",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<VideoModel>>(
        future: _trendVideos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: purpleColor));
          } else if (snapshot.hasError) {
            return _errorWidget(snapshot.error.toString());
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "Şu an trend video bulunmuyor.",
                style: TextStyle(color: Colors.white54),
              ),
            );
          }

          final videos = snapshot.data!;
          return RefreshIndicator(
            color: purpleColor,
            onRefresh: () async {
              setState(() {
                _trendVideos = _videoService.trendVideolariGetir();
              });
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: videos.length,
              itemBuilder: (context, index) {
                final video = videos[index];
                return _buildTrendCard(video, index + 1);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildTrendCard(VideoModel video, int rank) {
    final kapakUrl = _videoService.kapakResmiUrlAl(video.kapakResmiUrl);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: InkWell(
        onTap: () {
          // Tıklayınca İzle Sayfasına Gitme Fonksiyonu
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => IzlePage(
                video: video,
                currentUser: widget.currentUser,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  child: Image.network(
                    kapakUrl,
                    height: 210,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 210,
                        color: Colors.white10,
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    },
                    errorBuilder: (c, e, s) => Container(
                      height: 210,
                      color: Colors.grey[900],
                      child: const Icon(Icons.video_library, color: Colors.white24, size: 50),
                    ),
                  ),
                ),
                // Sıralama Rozeti (Rank)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: purpleColor,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                    ),
                    child: Text(
                      "#$rank",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: purpleColor.withOpacity(0.1),
                    child: Text(
                      video.kullaniciAdi.isNotEmpty ? video.kullaniciAdi[0].toUpperCase() : "?",
                      style: TextStyle(color: purpleColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          video.baslik,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "${video.kullaniciAdi} • ${video.izlenmeSayisi} izlenme",
                          style: const TextStyle(color: Colors.white54, fontSize: 13),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.favorite, color: Colors.redAccent, size: 16),
                            const SizedBox(width: 4),
                            Text("${video.likeSayisi}", style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            const SizedBox(width: 15),
                            Icon(Icons.remove_red_eye, color: purpleColor, size: 16),
                            const SizedBox(width: 4),
                            const Text("Trend", style: TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 60),
          const SizedBox(height: 10),
          Text("Hata: $error", style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: purpleColor),
            onPressed: () => setState(() => _trendVideos = _videoService.trendVideolariGetir()),
            child: const Text("Tekrar Dene"),
          )
        ],
      ),
    );
  }
}