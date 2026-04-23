import 'package:flutter/material.dart';
import '../services/abonelik_service.dart';
import '../services/video_service.dart';
import '../models/user_model.dart';
import '../models/video_model.dart';
import 'videolarim_page.dart';
import 'izle_page.dart';

class AboneliklerPage extends StatefulWidget {
  final UserModel currentUser;
  const AboneliklerPage({Key? key, required this.currentUser})
    : super(key: key);

  @override
  State<AboneliklerPage> createState() => _AboneliklerPageState();
}

class _AboneliklerPageState extends State<AboneliklerPage> {
  final AbonelikService _abonelikService = AbonelikService();
  final VideoService _videoService = VideoService();

  final Color bgColor = const Color(0xFF0F0F14);
  final Color cardColor = const Color(0xFF1A1A22);
  final Color purpleColor = const Color(0xFF8B5CF6);

  late Future<List<UserModel>> _aboneliklerFuture;

  @override
  void initState() {
    super.initState();
    _aboneliklerFuture = _getFollowingUsers();
  }

  Future<List<UserModel>> _getFollowingUsers() async {
    final response = await _abonelikService.getFollowing(widget.currentUser.id);
    return response
        .map(
          (u) => UserModel(
            id: u['id'],
            kullaniciAdi: u['kullaniciAdi'],
            email: u['email'],
            emailOnayli: true,
            aboneSayisi: 0,
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: const Text(
          "📺 Aboneliklerim",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.deepPurpleAccent),
      ),
      body: FutureBuilder<List<UserModel>>(
        future: _aboneliklerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _loadingSkeleton();
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Hata: ${snapshot.error}",
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          final users = snapshot.data ?? [];

          if (users.isEmpty) {
            return _emptyState();
          }

          return RefreshIndicator(
            color: purpleColor,
            onRefresh: () async {
              setState(() {
                _aboneliklerFuture = _getFollowingUsers();
              });
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: users.length,
              itemBuilder: (context, index) {
                return _buildUserCard(users[index]);
              },
            ),
          );
        },
      ),
    );
  }

  // 🔥 USER CARD
  Widget _buildUserCard(UserModel user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VideolarimPage(
                currentUser: user, // kanal sahibi
                loggedInUser: widget.currentUser, // 🔥 login user
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 25,
                backgroundColor: purpleColor.withOpacity(0.2),
                child: Text(
                  user.kullaniciAdi[0].toUpperCase(),
                  style: TextStyle(
                    color: purpleColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // USER INFO
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.kullaniciAdi,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // ACTION BUTTON
              InkWell(
                onTap: () => _openUserVideos(user),
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: purpleColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.play_arrow, color: purpleColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔥 USER VIDEOS MODAL
  void _openUserVideos(UserModel user) async {
    final videos = await _videoService.kullaniciVideolariniGetir(user.id);

    showModalBottomSheet(
      context: context,
      backgroundColor: bgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        if (videos.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Text("Video yok", style: TextStyle(color: Colors.white)),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: videos.length,
          itemBuilder: (context, i) {
            final video = videos[i];

            return ListTile(
              leading: Image.network(
                _videoService.kapakResmiUrlAl(video.kapakResmiUrl),
                width: 80,
                fit: BoxFit.cover,
              ),
              title: Text(
                video.baslik,
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                "${video.izlenmeSayisi} izlenme • ${video.likeSayisi} beğeni",
                style: const TextStyle(color: Colors.white54),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        IzlePage(video: video, currentUser: widget.currentUser),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // 🔥 EMPTY STATE
  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.subscriptions_outlined, size: 70, color: Colors.white10),
          SizedBox(height: 15),
          Text("Henüz abonelik yok", style: TextStyle(color: Colors.white38)),
        ],
      ),
    );
  }

  // 🔥 LOADING
  Widget _loadingSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: 6,
      itemBuilder: (_, __) => Container(
        height: 70,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }
}
