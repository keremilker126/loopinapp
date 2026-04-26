import 'package:flutter/material.dart';
import '../services/arama_service.dart';
import '../models/search_result.dart';
import '../models/video_model.dart';
import '../models/user_model.dart';
import 'izle_page.dart';
import 'videolarim_page.dart';

class AramaPage extends StatefulWidget {
  final String query;
  final UserModel? currentUser;

  const AramaPage({Key? key, required this.query, this.currentUser}) : super(key: key);

  @override
  State<AramaPage> createState() => _AramaPageState();
}

class _AramaPageState extends State<AramaPage> with SingleTickerProviderStateMixin {
  final AramaService _service = AramaService();
  late Future<SearchResult> _futureResult;
  late TabController _tabController;

  final Color bgColor = const Color(0xFF0F0F14);
  final Color cardColor = const Color(0xFF1A1A22);
  final Color purpleColor = const Color(0xFF8B5CF6);

  @override
  void initState() {
    super.initState();
    _futureResult = _service.search(widget.query);
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,

      // 🔥 MODERN APPBAR
      appBar: AppBar(
        elevation: 0,
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
        title: Text("🔍 ${widget.query}",style: TextStyle(color: Colors.white,fontSize: 20),),
        centerTitle: true,

        bottom: TabBar(
          controller: _tabController,
          indicatorColor: purpleColor,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white38,
          tabs: const [
            Tab(text: "Videolar"),
            Tab(text: "Kanallar"),
          ],
        ),
        iconTheme: IconThemeData(color: purpleColor),

      ),

      body: FutureBuilder<SearchResult>(
        future: _futureResult,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: purpleColor));
          }

          if (snapshot.hasError) {
            return Center(
              child: Text("Hata: ${snapshot.error}",
                  style: const TextStyle(color: Colors.white)),
            );
          }

          final result = snapshot.data!;

          return TabBarView(
            controller: _tabController,
            children: [
              _buildVideos(result),
              _buildUsers(result),
            ],
          );
        },
      ),
    );
  }

  // 🎬 VIDEOLAR TAB
  Widget _buildVideos(SearchResult result) {
    if (result.videolar.isEmpty) {
      return _emptyState("Video bulunamadı");
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: result.videolar.length,
      itemBuilder: (context, index) {
        final v = result.videolar[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 15,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              final videoModel = VideoModel(
                id: v.id,
                baslik: v.baslik,
                kapakResmiUrl: v.kapakResmiUrl,
                videoUrl: v.videoUrl,
                aciklama: v.aciklama,
                yuklenmeTarihi: DateTime.parse(v.yuklenmeTarihi),
                izlenmeSayisi: v.izlenmeSayisi,
                likeSayisi: v.likeSayisi,
                kullaniciId: v.kullaniciId,
                kullaniciAdi: v.kullaniciAdi,
                aboneSayisi: v.aboneSayisi,
              );

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => IzlePage(
                    video: videoModel,
                    currentUser: widget.currentUser,
                  ),
                ),
              );
            },
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
                  child: Image.network(
                    "http://10.0.2.2:5144/${v.kapakResmiUrl}",
                    width: 130,
                    height: 85,
                    fit: BoxFit.cover,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          v.baslik,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "${v.kullaniciAdi} • ${v.izlenmeSayisi} izlenme",
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  // 👤 KANALLAR TAB
  Widget _buildUsers(SearchResult result) {
    if (result.kullanicilar.isEmpty) {
      return _emptyState("Kanal bulunamadı");
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: result.kullanicilar.length,
      itemBuilder: (context, index) {
        final u = result.kullanicilar[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: cardColor,
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: purpleColor.withOpacity(0.2),
              child: Text(
                u.kullaniciAdi[0].toUpperCase(),
                style: TextStyle(color: purpleColor),
              ),
            ),
            title: Text(u.kullaniciAdi,
                style: const TextStyle(color: Colors.white)),
            subtitle: Text(u.email,
                style: const TextStyle(color: Colors.white54)),
            onTap: () {
              final userModel = UserModel(
                id: u.id,
                kullaniciAdi: u.kullaniciAdi,
                email: u.email,
                emailOnayli: u.emailOnayli,
                aboneSayisi: 0,
              );

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideolarimPage(
                    currentUser: userModel,
                    loggedInUser: widget.currentUser,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // 🧊 EMPTY STATE
  Widget _emptyState(String text) {
    return Center(
      child: Text(
        text,
        style: const TextStyle(color: Colors.white38),
      ),
    );
  }
}