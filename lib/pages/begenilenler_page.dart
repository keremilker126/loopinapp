import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/video_model.dart';
import '../services/begenme_service.dart';
import '../services/video_service.dart';
import 'izle_page.dart';

class BegenilenlerPage extends StatefulWidget {
  final UserModel currentUser;

  const BegenilenlerPage({Key? key, required this.currentUser}) : super(key: key);

  @override
  State<BegenilenlerPage> createState() => _BegenilenlerPageState();
}

class _BegenilenlerPageState extends State<BegenilenlerPage> {
  final BegenmeService _begenmeService = BegenmeService();
  final VideoService _videoService = VideoService();

  final Color bgColor = const Color(0xFF0F0F14);
  final Color cardColor = const Color(0xFF1A1A22);
  final Color purpleColor = const Color(0xFF8B5CF6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,

      // 🔥 MODERN APPBAR
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black, bgColor],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.favorite, color: Colors.deepPurpleAccent),
            const SizedBox(width: 8),
            const Text(
              "Beğenilenler",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
            ),
          ],
        ),
        iconTheme: IconThemeData(color: purpleColor),
      ),

      body: FutureBuilder<List<VideoModel>>(
        future: _begenmeService.getLikedVideos(widget.currentUser.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(color: purpleColor));
          }

          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }

          final videolar = snapshot.data ?? [];

          if (videolar.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            color: purpleColor,
            onRefresh: () async => setState(() {}),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              itemCount: videolar.length,
              itemBuilder: (context, index) {
                final video = videolar[index];
                return _buildLikedVideoCard(video);
              },
            ),
          );
        },
      ),
    );
  }

  // 🔥 MODERN VIDEO CARD
  Widget _buildLikedVideoCard(VideoModel video) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),

        // 👉 NORMAL TIKLAMA
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  IzlePage(video: video, currentUser: widget.currentUser),
            ),
          ).then((_) => setState(() {}));
        },

        // ❗ LONG PRESS → CONFIRM
        onLongPress: () async {
          bool silinsinMi = await _showUnlikeDialog(video);
          if (silinsinMi) {
            _handleRemoveLike(video);
          }
        },

        child: Ink(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              // THUMBNAIL
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(14)),
                child: Image.network(
                  _videoService.kapakResmiUrlAl(video.kapakResmiUrl),
                  width: 130,
                  height: 85,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 130,
                    height: 85,
                    color: Colors.white10,
                    child: const Icon(Icons.broken_image,
                        color: Colors.white24),
                  ),
                ),
              ),

              // INFO
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        video.baslik,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "${video.izlenmeSayisi} izlenme • ${video.kullaniciAdi}",
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),

              const Padding(
                padding: EdgeInsets.only(right: 12),
                child: Icon(Icons.favorite,
                    color: Colors.deepPurpleAccent, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔥 MODERN CONFIRM DIALOG
  Future<bool> _showUnlikeDialog(VideoModel video) async {
    final result = await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: cardColor,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.heart_broken,
                    color: Colors.redAccent, size: 50),
                const SizedBox(height: 15),

                const Text(
                  "Beğeniyi kaldır?",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                Text(
                  "'${video.baslik}' beğenilenlerden kaldırılsın mı?",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white54),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () =>
                            Navigator.pop(context, false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(color: Colors.white24),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text("İptal"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () =>
                            Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text("Kaldır"),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );

    return result ?? false;
  }

  void _handleRemoveLike(VideoModel video) async {
    final success = await _begenmeService.removeLike(
        widget.currentUser.id, video.id);

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text("'${video.baslik}' kaldırıldı"),
            backgroundColor: purpleColor,
          ),
        );
        setState(() {});
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("İşlem başarısız"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.favorite_border,
              color: Colors.white10, size: 80),
          SizedBox(height: 16),
          Text("Henüz beğenilen video yok",
              style: TextStyle(color: Colors.white38)),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off,
                color: Colors.redAccent, size: 50),
            const SizedBox(height: 16),
            Text("Hata: $error",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white54)),
            TextButton(
                onPressed: () => setState(() {}),
                child: const Text("Tekrar Dene"))
          ],
        ),
      ),
    );
  }
}