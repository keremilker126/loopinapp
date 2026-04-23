import 'package:flutter/material.dart';
import 'package:loopin/models/daha_sonra_izle_model.dart';
import 'package:loopin/pages/admin_panel_page.dart';
import 'package:loopin/pages/arama_page.dart';
import 'package:loopin/pages/begenilenler_page.dart';
import 'package:loopin/pages/change_password_page.dart';
import 'package:loopin/pages/daha_sonra_izle_page.dart';
import 'package:loopin/pages/izle_page.dart';
import 'package:loopin/pages/trends_page.dart';
import 'package:loopin/pages/video_yukle_page.dart';
import 'package:loopin/pages/videolarim_page.dart';
import 'package:loopin/services/admin_service.dart';

import '../models/user_model.dart';

import '../models/video_model.dart';

import '../services/video_service.dart';
import '../services/daha_sonra_izle_service.dart';
import '../services/daha_sonra_izle_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Tasarım Renkleri

  final Color bgColor = const Color(0xFF0F0F14);

  final Color cardColor = const Color(0xFF1A1A22);

  final Color purpleColor = const Color(0xFF5E5CE6);

  // Servis Tanımı

  final adminService = AdminService();
  final VideoService _videoService = VideoService();

  // API base URL (Resim yolları için gerekli)

  final String apiBaseUrl =
      "http://localhost:5144"; // Kendi API adresinize göre güncelle (Örn: http://localhost:5144)

  // --- ADMIN LİSTESİ ---

  final List<String> _adminEmails = [
    'keremilker56@gmail.com',

    'keremilker126@gmail.com',

    'mehmedkaan46@gmail.com',
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lütfen önce giriş yapın.')),
        );
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        _showWelcomeDialog();
      }
    });
  }

  UserModel? get _currentUser {
    return ModalRoute.of(context)!.settings.arguments as UserModel?;
  }

  bool get _isAdmin {
    return _adminEmails.contains(_currentUser?.email?.toLowerCase().trim());
  }

  // --- ÇIKIŞ ONAY PENCERESİ ---

  void _showLogoutDialog() {
    showDialog(
      context: context,

      builder: (context) => AlertDialog(
        backgroundColor: cardColor,

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

        title: const Text("Çıkış Yap", style: TextStyle(color: Colors.white)),

        content: const Text(
          "Hesabınızdan çıkış yapmak istediğinize emin misiniz?",

          style: TextStyle(color: Colors.white70),
        ),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),

            child: const Text(
              "Vazgeç",
              style: TextStyle(color: Colors.white54),
            ),
          ),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent.withOpacity(0.8),

              foregroundColor: Colors.white,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            onPressed: () {
              Navigator.pop(context);

              Navigator.pushReplacementNamed(context, '/login');
            },

            child: const Text("Çıkış Yap"),
          ),
        ],
      ),
    );
  }

  void _showWelcomeDialog() {
    showDialog(
      context: context,

      barrierDismissible: false,

      builder: (context) => AlertDialog(
        backgroundColor: cardColor,

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

        title: Row(
          children: [
            Icon(Icons.stars, color: purpleColor),

            const SizedBox(width: 10),

            const Text("Giriş Başarılı", style: TextStyle(color: Colors.white)),
          ],
        ),

        content: Text(
          "Hoş geldin, ${_currentUser?.kullaniciAdi ?? 'Kullanıcı'}!\nLoopin dünyasını keşfetmeye hazır mısın?",

          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),

        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: purpleColor,

              foregroundColor: Colors.white,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            onPressed: () => Navigator.pop(context),

            child: const Text("Keşfet"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,

      drawer: _buildDrawer(),

      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        iconTheme: IconThemeData(color: purpleColor),
        title: TextField(
          style: const TextStyle(color: Colors.white),
          cursorColor: purpleColor,
          decoration: InputDecoration(
            hintText: "Ara...",
            hintStyle: const TextStyle(color: Colors.white54),
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search, color: purpleColor),
          ),
          onSubmitted: (query) {
            if (query.trim().isNotEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AramaPage(
                    query: query.trim(),
                    currentUser: _currentUser, // 🔥 login user gönderiliyor
                  ),
                ),
              );
            }
          },
        ),
        actions: [
          IconButton(
            onPressed: _showLogoutDialog,
            icon: Icon(Icons.logout, color: purpleColor),
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {}); // Sayfayı aşağı çekince verileri yeniler
        },

        child: FutureBuilder<List<VideoModel>>(
          future: _videoService.tumVideolariGetir(),

          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  "Hata: ${snapshot.error}",

                  style: const TextStyle(color: Colors.white70),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  "Henüz hiç video yüklenmemiş.",

                  style: TextStyle(color: Colors.white54),
                ),
              );
            }

            final videolar = snapshot.data!;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),

              physics: const AlwaysScrollableScrollPhysics(),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    "Hoş Geldin ${_currentUser?.kullaniciAdi ?? ''} 👋",

                    style: const TextStyle(
                      color: Colors.white,

                      fontSize: 24,

                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    "Senin için önerilen içerikler burada",

                    style: TextStyle(color: Colors.white.withOpacity(0.5)),
                  ),

                  const SizedBox(height: 25),

                  Row(
                    children: [
                      Icon(Icons.whatshot, color: purpleColor, size: 28),

                      const SizedBox(width: 8),

                      const Text(
                        "En Yeni Videolar",

                        style: TextStyle(
                          color: Colors.white,

                          fontSize: 20,

                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Dinamik Video Listesi
                  ListView.separated(
                    shrinkWrap: true,

                    physics: const NeverScrollableScrollPhysics(),

                    itemCount: videolar.length,

                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 20),

                    itemBuilder: (context, index) {
                      final video = videolar[index];
                      print(
                        "Video ${video.id}: kapakResmiUrl = '${video.kapakResmiUrl}'",
                      );
                      return _buildVideoCard(video: video);
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: bgColor.withOpacity(0.95),

      child: ListView(
        padding: EdgeInsets.zero,

        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: purpleColor.withOpacity(0.2)),
              ),
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                CircleAvatar(
                  backgroundColor: purpleColor.withOpacity(0.2),

                  radius: 30,

                  child: Icon(Icons.person, color: purpleColor, size: 30),
                ),

                const SizedBox(height: 10),

                Text(
                  _currentUser?.kullaniciAdi ?? "Loopin Kullanıcısı",

                  style: const TextStyle(
                    color: Colors.white,

                    fontSize: 18,

                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text(
                  _currentUser?.email ?? "",

                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          _drawerItem(Icons.home, "Ana Sayfa", active: true),

          if (_isAdmin)
            _drawerItem(
              Icons.admin_panel_settings,

              "Admin Paneli",

              onTap: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AdminPanelPage(currentUser: _currentUser!),
                  ),
                );
              },
            ),

          _drawerItem(
            Icons.upload,
            "Video Yükle",
            onTap: () {
              Navigator.pop(context);
              if (_currentUser == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Giriş yapmadan bu sayfaya erişemezsiniz.'),
                  ),
                );
                Navigator.pushReplacementNamed(context, '/login');
                return;
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      VideoYuklePage(currentUserId: _currentUser!.id!),
                ),
              );
            },
          ),

          _drawerItem(
            Icons.trending_up,
            "Trendler",
            onTap: () {
              Navigator.pop(context);
              if (_currentUser == null) {
                // ... giriş kontrolü ...
                return;
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TrendsPage(
                    currentUser: _currentUser,
                  ), // currentUser eklendi
                ),
              );
            },
          ),

          _drawerItem(
            Icons.folder_special,
            "Videolarım",
            onTap: () {
              Navigator.pop(context);
              if (_currentUser == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Giriş yapmadan bu sayfaya erişemezsiniz.'),
                  ),
                );
                Navigator.pushReplacementNamed(context, '/login');
                return;
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideolarimPage(
                    currentUser: _currentUser!,
                    loggedInUser: _currentUser,
                  ),
                ),
              );
            },
          ),

          _drawerItem(
            Icons.watch_later,
            "Daha Sonra İzle",
            onTap: () {
              Navigator.pop(context);
              if (_currentUser == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Giriş yapmadan bu sayfaya erişemezsiniz.'),
                  ),
                );
                Navigator.pushReplacementNamed(context, '/login');
                return;
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DahaSonraIzlePage(
                    userId: _currentUser!.id!,
                    currentUser: _currentUser, // 🔥 login user gönderiliyor
                  ),
                ),
              );
            },
          ),

          _drawerItem(
            Icons.favorite,
            "Beğendiklerim",
            onTap: () {
              Navigator.pop(context);
              if (_currentUser == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Giriş yapmadan bu sayfaya erişemezsiniz.'),
                  ),
                );
                Navigator.pushReplacementNamed(context, '/login');
                return;
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      BegenilenlerPage(currentUser: _currentUser!),
                ),
              );
            },
          ),

          const Divider(color: Colors.white10),

          _drawerItem(
            Icons.password,

            "Parola Değiştir",

            onTap: () {
              Navigator.pop(context);

              if (_currentUser == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Giriş yapmadan bu sayfaya erişemezsiniz.'),
                  ),
                );
                Navigator.pushReplacementNamed(context, '/login');
                return;
              }

              Navigator.push(
                context,

                MaterialPageRoute(
                  builder: (context) => ChangePasswordPage(user: _currentUser!),
                ),
              );
            },
          ),

          _drawerItem(
            Icons.logout,

            "Çıkış Yap",

            onTap: () {
              Navigator.pop(context);

              _showLogoutDialog();
            },
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(
    IconData icon,
    String title, {
    bool active = false,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: active ? purpleColor : Colors.white70),

      title: Text(
        title,

        style: TextStyle(
          color: active ? purpleColor : Colors.white70,

          fontWeight: active ? FontWeight.bold : FontWeight.normal,
        ),
      ),

      onTap: onTap ?? () {},

      selected: active,
    );
  }

  Widget _buildVideoCard({required VideoModel video}) {
    final kapakUrl =
        video.kapakResmiUrl != null && video.kapakResmiUrl!.startsWith("http")
        ? video.kapakResmiUrl!
        : "$apiBaseUrl/${video.kapakResmiUrl}";

    print("Kapak URL: '$kapakUrl'");

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                IzlePage(video: video, currentUser: _currentUser),
          ),
        );
      },
      onLongPress: () {
        _showVideoOptions(video);
      },
      child: Card(
        color: cardColor,
        child: Column(
          children: [
            Image.network(
              kapakUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: 200,
                  color: Colors.grey,
                  child: const Center(child: CircularProgressIndicator()),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                print("Resim yükleme hatası: $error");
                return const Icon(Icons.error, color: Colors.white);
              },
            ),
            ListTile(
              title: Text(
                video.baslik,
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                "${video.kullaniciAdi} • ${video.izlenmeSayisi} İzlenme",
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showVideoOptions(VideoModel video) {
    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              video.baslik,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.watch_later, color: purpleColor),
              title: const Text(
                "Daha Sonra İzle",
                style: TextStyle(color: Colors.white),
              ),
              onTap: () async {
                Navigator.pop(context);
                await _addToWatchLater(video);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addToWatchLater(VideoModel video) async {
    if (_currentUser == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Giriş yapmalısınız")));
      return;
    }

    try {
      final dahaSonraIzleService = DahaSonraIzleService();
      final result = await dahaSonraIzleService.toggle(
        DahaSonraIzleDto(kullaniciId: _currentUser!.id, videoId: video.id),
      );

      if (result == "added") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("'${video.baslik}' daha sonra izlemeye eklendi"),
          ),
        );
      } else if (result == "removed") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "'${video.baslik}' daha sonra izle listesinden kaldırıldı",
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("İşlem başarısız")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Hata: $e")));
    }
  }
}
