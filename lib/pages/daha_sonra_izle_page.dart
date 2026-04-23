import 'package:flutter/material.dart';
import 'package:loopin/models/daha_sonra_izle_model.dart';
import 'package:loopin/models/user_model.dart';
import 'package:loopin/pages/izle_page.dart';
import '../models/video_model.dart';
import '../services/daha_sonra_izle_service.dart';

class DahaSonraIzlePage extends StatefulWidget {
  final int userId;
  final UserModel? currentUser; // 🔥 login user

  const DahaSonraIzlePage({super.key, required this.userId, this.currentUser});

  @override
  State<DahaSonraIzlePage> createState() => _DahaSonraIzlePageState();
}

class _DahaSonraIzlePageState extends State<DahaSonraIzlePage> {
  final service = DahaSonraIzleService();
  late Future<List<VideoModel>> futureList;

  final Color bgColor = const Color(0xFF0F0F14);
  final Color cardColor = const Color(0xFF1A1A22);
  final Color purpleColor = const Color(0xFF8B5CF6);

  final String apiBaseUrl = "http://localhost:5144";

  @override
  void initState() {
    super.initState();
    _refreshList();
  }

  void _refreshList() {
    setState(() {
      futureList = service.getList(widget.userId);
    });
  }

  // ✅ MODERN CONFIRM DIALOG
  Future<void> _confirmRemove(int videoId) async {
    final result = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 50,
                ),
                const SizedBox(height: 15),
                const Text(
                  "Listeden kaldır?",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Bu videoyu daha sonra izle listesinden kaldırmak istediğine emin misin?",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white54),
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(color: Colors.white24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text("İptal"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text("Sil"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (result == true) {
      _toggleVideo(videoId);
    }
  }

  void _toggleVideo(int videoId) async {
    final dto = DahaSonraIzleDto(kullaniciId: widget.userId, videoId: videoId);

    final status = await service.toggle(dto);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == "added" ? "📌 Listeye eklendi" : "🗑 Listeden kaldırıldı",
          ),
          backgroundColor: purpleColor,
        ),
      );
      _refreshList();
    }
  }

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
            Icon(Icons.watch_later, color: purpleColor),
            const SizedBox(width: 8),
            const Text(
              "Daha Sonra İzle",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ],
        ),
        iconTheme: IconThemeData(color: purpleColor),
      ),

      body: FutureBuilder<List<VideoModel>>(
        future: futureList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _loadingSkeleton();
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "Hata: ${snapshot.error}",
                style: const TextStyle(color: Colors.white),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "📭 Liste boş",
                style: TextStyle(color: Colors.white54),
              ),
            );
          }

          final videos = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: videos.length,
            itemBuilder: (context, index) {
              return _buildVideoCard(videos[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildVideoCard(VideoModel video) {
    final kapakUrl = video.kapakResmiUrl.startsWith("http")
        ? video.kapakResmiUrl
        : "$apiBaseUrl/${video.kapakResmiUrl}";

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => IzlePage(
              video: video,
              currentUser: widget.currentUser, // 🔥 login user gönderiliyor
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                  child: Image.network(
                    kapakUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),

                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),

                // ❗ BURASI DEĞİŞTİ (CONFIRM EKLENDİ)
                Positioned(
                  top: 10,
                  right: 10,
                  child: InkWell(
                    onTap: () => _confirmRemove(video.id),
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),

                const Positioned.fill(
                  child: Center(
                    child: Icon(
                      Icons.play_circle_fill,
                      size: 60,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: purpleColor.withOpacity(0.2),
                    child: Text(
                      video.kullaniciAdi[0].toUpperCase(),
                      style: TextStyle(color: purpleColor),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          video.baslik,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${video.kullaniciAdi} • ${video.izlenmeSayisi} izlenme",
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 13,
                          ),
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

  Widget _loadingSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: 5,
      itemBuilder: (_, __) => Container(
        height: 220,
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }
}
