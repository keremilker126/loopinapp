import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/video_model.dart';
import '../models/abonelik_model.dart';
import '../services/video_service.dart';
import '../services/abonelik_service.dart';
import 'izle_page.dart';

class VideolarimPage extends StatefulWidget {
  final UserModel currentUser;
  final UserModel? loggedInUser; // Şu anda login olan kullanıcı

  const VideolarimPage({
    Key? key, 
    required this.currentUser,
    this.loggedInUser,
  }) : super(key: key);

  @override
  State<VideolarimPage> createState() => _VideolarimPageState();
}

class _VideolarimPageState extends State<VideolarimPage> {
  final VideoService _videoService = VideoService();
  final AbonelikService _abonelikService = AbonelikService();
  
  // Tasarım Renkleri
  final Color bgColor = const Color(0xFF0F0F14);
  final Color cardColor = const Color(0xFF1A1A22);
  final Color purpleColor = const Color(0xFF5E5CE6);

  int _aboneSayisi = 0;
  bool _isLoading = true;
  String _sortType = 'en_yeni'; // Sıralama türü
  bool _isSubscribed = false;
  bool _isLoadingSubscription = false;

  @override
  void initState() {
    super.initState();
    _loadAbonerCount();
  }

  Future<void> _loadAbonerCount() async {
    try {
      final response = await _abonelikService.checkSubscriptionStatus(
        widget.currentUser.id,
        widget.currentUser.id,
      );
      
      // Eğer başkasının kanalı bakıyorsa, abone durumunu kontrol et
      bool subStatus = false;
      if (widget.loggedInUser != null && widget.loggedInUser!.id != widget.currentUser.id) {
        final subCheck = await _abonelikService.checkSubscriptionStatus(
          widget.loggedInUser!.id,
          widget.currentUser.id,
        );
        subStatus = subCheck['isSubscribed'] ?? false;
      }
      
      // Minimum 1 saniye loading göster
      await Future.delayed(const Duration(seconds: 1));
      
      if (mounted) {
        setState(() {
          _aboneSayisi = response['subscriberCount'] ?? 0;
          _isSubscribed = subStatus;
          _isLoading = false;
        });
      }
    } catch (e) {
      _aboneSayisi = 0;
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: bgColor,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            "Videolarım", 
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)
          ),
          iconTheme: IconThemeData(color: purpleColor),
        ),
        body: Center(
          child: CircularProgressIndicator(color: purpleColor),
        ),
      );
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Videolarım", 
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)
        ),
        iconTheme: IconThemeData(color: purpleColor),
      ),
      body: Column(
        children: [
          _buildProfileHeader(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Divider(color: Colors.white10, thickness: 1),
          ),
          Expanded(
            child: _buildUserVideoList(),
          ),
        ],
      ),
    );
  }

  // Üst Kısım: Profil Resmi, İsim ve Güncel Abone Sayısı
  Widget _buildProfileHeader() {
    final bool isOwnProfile = widget.loggedInUser?.id == widget.currentUser.id || widget.loggedInUser == null;
    
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: purpleColor.withOpacity(0.1),
            child: Text(
              widget.currentUser.kullaniciAdi.isNotEmpty 
                  ? widget.currentUser.kullaniciAdi[0].toUpperCase() 
                  : "?",
              style: TextStyle(color: purpleColor, fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.currentUser.kullaniciAdi,
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.people_outline, color: purpleColor, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      // API'den gerçek abone sayısını çekiyoruz
                      "$_aboneSayisi Abone", 
                      style: const TextStyle(color: Colors.white60, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Başkasının kanalı bakıyorsa abone ol/çık butonu göster
          if (!isOwnProfile)
            ElevatedButton(
              onPressed: _isLoadingSubscription ? null : _toggleSubscribe,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isSubscribed ? Colors.white10 : purpleColor,
                foregroundColor: _isSubscribed ? Colors.white : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: _isLoadingSubscription
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(_isSubscribed ? "Abonelikten Çık" : "Abone Ol"),
            ),
        ],
      ),
    );
  }

  // Alt Kısım: API'den gelen kullanıcı videoları
  Widget _buildUserVideoList() {
    return FutureBuilder<List<VideoModel>>(
      // VideoService'e yeni eklediğimiz kullanıcıya özel metodu çağırıyoruz
      future: _videoService.kullaniciVideolariniGetir(widget.currentUser.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: purpleColor));
        }
        
        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Hata: ${snapshot.error}", 
              style: const TextStyle(color: Colors.redAccent)
            ),
          );
        }

        var videolar = snapshot.data ?? [];
        
        // Videoları seçilen tipe göre sırala
        videolar = _sortVideos(videolar);

        if (videolar.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.video_collection_outlined, color: Colors.white10, size: 100),
                const SizedBox(height: 16),
                const Text(
                  "Henüz bir video paylaşmadınız.", 
                  style: TextStyle(color: Colors.white38, fontSize: 16)
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Filtreleme Dropdown
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: DropdownButton<String>(
                value: _sortType,
                dropdownColor: cardColor,
                style: const TextStyle(color: Colors.white),
                underline: Container(
                  height: 2,
                  color: purpleColor,
                ),
                items: const [
                  DropdownMenuItem(value: 'en_yeni', child: Text('En Yeni')),
                  DropdownMenuItem(value: 'en_eski', child: Text('En Eski')),
                  DropdownMenuItem(value: 'en_cok_izlenen', child: Text('En Çok İzlenen')),
                  DropdownMenuItem(value: 'en_begenilen', child: Text('En Beğenilen')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _sortType = value;
                    });
                  }
                },
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                itemCount: videolar.length,
                itemBuilder: (context, index) {
                  final video = videolar[index];
                  return _buildSmallVideoCard(video);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // Videoları sırala
  List<VideoModel> _sortVideos(List<VideoModel> videos) {
    // Listeyi kopyala (immutable liste sorunu için)
    final sortedVideos = List<VideoModel>.from(videos);
    
    switch (_sortType) {
      case 'en_eski':
        sortedVideos.sort((a, b) => a.id.compareTo(b.id));
        break;
      case 'en_cok_izlenen':
        sortedVideos.sort((a, b) => b.izlenmeSayisi.compareTo(a.izlenmeSayisi));
        break;
      case 'en_begenilen':
        sortedVideos.sort((a, b) => b.likeSayisi.compareTo(a.likeSayisi));
        break;
      case 'en_yeni':
      default:
        sortedVideos.sort((a, b) => b.id.compareTo(a.id));
        break;
    }
    return sortedVideos;
  }

  // Abone ol/çık toggle
  Future<void> _toggleSubscribe() async {
    if (widget.loggedInUser == null) {
      _showError("Abonelik için giriş yapmalısınız.");
      return;
    }

    setState(() => _isLoadingSubscription = true);

    try {
      final model = AbonelikModel(
        aboneOlanId: widget.loggedInUser!.id,
        aboneOlunanId: widget.currentUser.id,
      );

      final result = await _abonelikService.toggleSubscription(model);

      if (result != null && mounted) {
        setState(() {
          _isSubscribed = (result['status'] == "subscribed");
          _aboneSayisi = result['currentSubscriberCount'] ?? _aboneSayisi;
        });
      }
    } catch (e) {
      _showError("Abonelik işlemi başarısız: $e");
    } finally {
      if (mounted) setState(() => _isLoadingSubscription = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Video Kart Tasarımı
  Widget _buildSmallVideoCard(VideoModel video) {
    return InkWell( // GestureDetector yerine InkWell daha iyi bir tıklama efekti verir
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => IzlePage(video: video, currentUser: widget.currentUser),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Video Thumbnail
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
              child: Image.network(
                _videoService.kapakResmiUrlAl(video.kapakResmiUrl),
                width: 130,
                height: 85,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => 
                  Container(width: 130, height: 85, color: Colors.white10, child: const Icon(Icons.broken_image, color: Colors.white24)),
              ),
            ),
            // Video Detayları
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.baslik,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${video.izlenmeSayisi} izlenme • ${video.likeSayisi} beğeni",
                      style: const TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
            // İşlemler (Sil/Düzenle)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white54, size: 20),
              color: cardColor,
              onSelected: (value) async {
                if (value == 'delete') {
                  _showDeleteDialog(video);
                } else if (value == 'edit') {
                  _showEditDialog(video);
                }
              },
              itemBuilder: (BuildContext context) => [
                
                const PopupMenuItem(value: 'delete', child: Text('Sil', style: TextStyle(color: Colors.redAccent))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(VideoModel video) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Videoyu Sil", style: TextStyle(color: Colors.white)),
        content: const Text(
          "Bu videoyu silmek istediğinize emin misiniz?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Vazgeç", style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(context);
              await _videoService.videoSil(video.id);
              setState(() {}); // Listeyi yenile
            },
            child: const Text("Sil"),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(VideoModel video) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Video Düzenle", style: TextStyle(color: Colors.white)),
        content: const Text(
          "Video düzenleme özelliği yakında eklenecek.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: purpleColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text("Tamam"),
          ),
        ],
      ),
    );
  }
}