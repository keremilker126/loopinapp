import 'package:flutter/material.dart';
import '../models/video_model.dart';
import '../models/user_model.dart';
import '../services/admin_service.dart';
import '../services/video_service.dart';

class AdminPanelPage extends StatefulWidget {
  final UserModel currentUser;

  const AdminPanelPage({super.key, required this.currentUser});

  @override
  State<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage> {
  final Color bgColor = const Color(0xFF0F0F14);
  final Color cardColor = const Color(0xFF1A1A22);
  final Color purpleColor = const Color(0xFF5E5CE6);
  final Color dangerColor = Colors.redAccent.withOpacity(0.8);

  final AdminService _adminService = AdminService();
  final VideoService _videoService = VideoService();

  List<VideoModel> videolar = [];
  List<UserModel> kullanicilar = [];
  List<String> engellenenMailler = []; // 📌 Yeni: Engellenenler listesi
  
  List<VideoModel> _filteredVideolar = [];
  List<UserModel> _filteredKullanicilar = [];

  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAll();
    _searchController.addListener(_performSearch);
  }

  void _performSearch() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredKullanicilar = kullanicilar
          .where((user) =>
              user.kullaniciAdi.toLowerCase().contains(query) ||
              user.email.toLowerCase().contains(query))
          .toList();

      _filteredVideolar = videolar
          .where((video) =>
              video.baslik.toLowerCase().contains(query) ||
              video.kullaniciAdi.toLowerCase().contains(query))
          .toList();
    });
  }

  Future<void> _loadAll() async {
    setState(() => _isLoading = true);
    try {
      // 📌 Backend'deki 3 farklı veriyi aynı anda çekiyoruz
      final results = await Future.wait([
        _videoService.tumVideolariGetir(),
        _adminService.getAllUsers(widget.currentUser.email),
        _adminService.getBlockedEmails(widget.currentUser.email), // 📌 Yeni servis metodun
      ]);

      videolar = results[0] as List<VideoModel>;
      kullanicilar = results[1] as List<UserModel>;
      engellenenMailler = results[2] as List<String>;
      
      _filteredVideolar = videolar;
      _filteredKullanicilar = kullanicilar;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 📌 Engelleme Onay Dialog'u: hem e-posta engelle hem hesap sil
  void _confirmBlock(UserModel user) {
    _confirmAction(
      title: "Kullanıcıyı Engelle ve Sil",
      content: "${user.kullaniciAdi} hesabı engellensin ve silinsin mi?",
      actionText: "Engelle ve Sil",
      actionColor: Colors.orangeAccent,
      onConfirm: () async {
        final blockResult = await _adminService.blockEmail(user.email, widget.currentUser.email);
        if (!blockResult['success']) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(blockResult['message'] ?? 'Engelleme başarısız oldu.'), backgroundColor: Colors.red),
            );
          }
          return;
        }

        final deleted = await _adminService.deleteUser(user.id, widget.currentUser.email);
        if (deleted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Kullanıcı engellendi ve silindi.'), backgroundColor: Colors.green),
            );
            _loadAll();
          }
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kullanıcı engellendi, fakat silme işleminde hata oluştu.'), backgroundColor: Colors.orange),
          );
          _loadAll();
        }
      },
    );
  }

  // Genel Onay Penceresi (Kod tekrarını önlemek için)
  void _confirmAction({
    required String title,
    required String content,
    required String actionText,
    required Color actionColor,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: Text(content, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Vazgeç", style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: actionColor),
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: Text(actionText, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        iconTheme: IconThemeData(color: purpleColor),
        title: const Text("Yönetim Paneli", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: purpleColor),
            onPressed: _isLoading ? null : _loadAll,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: purpleColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  _buildSearchBar(),
                  const SizedBox(height: 25),
                  _buildSectionHeader("Kullanıcılar", Icons.group, _filteredKullanicilar.length),
                  const SizedBox(height: 15),
                  _buildUserList(),
                  const SizedBox(height: 30),
                  _buildSectionHeader("Videolar", Icons.video_library, _filteredVideolar.length),
                  const SizedBox(height: 15),
                  _buildVideoList(),
                  const SizedBox(height: 30),
                  _buildSectionHeader("Engellenen E-postalar", Icons.block, engellenenMailler.length),
                  const SizedBox(height: 15),
                  _buildBlockedList(),
                  const SizedBox(height: 50),
                ],
              ),
            ),
    );
  }

  Widget _buildUserList() {
    if (_filteredKullanicilar.isEmpty) return _emptyState("Kullanıcı bulunamadı");
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredKullanicilar.length,
      itemBuilder: (context, index) {
        final user = _filteredKullanicilar[index];
        return _adminListItem(
          title: user.kullaniciAdi,
          subtitle: user.email,
          icon: Icons.person_outline,
          // 📌 Kullanıcılar için hem SİL hem ENGELLE butonu
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.block, color: Colors.orangeAccent, size: 20),
                onPressed: () => _confirmBlock(user),
                tooltip: "Engelle ve Sil",
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                onPressed: () => _confirmAction(
                  title: "Kullanıcıyı Sil",
                  content: "${user.kullaniciAdi} silinsin mi?",
                  actionText: "Sil",
                  actionColor: Colors.redAccent,
                  onConfirm: () async {
                    await _adminService.deleteUser(user.id, widget.currentUser.email);
                    _loadAll();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVideoList() {
    if (_filteredVideolar.isEmpty) return _emptyState("Video bulunamadı");
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredVideolar.length,
      itemBuilder: (context, index) {
        final video = _filteredVideolar[index];
        return _adminListItem(
          title: video.baslik,
          subtitle: "${video.kullaniciAdi} • ${video.izlenmeSayisi} izlenme",
          icon: Icons.play_circle_outline,
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
            onPressed: () => _confirmAction(
              title: "Videoyu Sil",
              content: "Bu video silinsin mi?",
              actionText: "Sil",
              actionColor: Colors.redAccent,
              onConfirm: () async {
                await _adminService.deleteVideo(video.id, widget.currentUser.email);
                _loadAll();
              },
            ),
          ),
        );
      },
    );
  }

  // 📌 Yeni: Engellenen Mailler Listesi UI
 Widget _buildBlockedList() {
  if (engellenenMailler.isEmpty) return _emptyState("Henüz engellenen kimse yok");
  return ListView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: engellenenMailler.length,
    itemBuilder: (context, index) {
      final email = engellenenMailler[index];
      return _adminListItem(
        title: email,
        subtitle: "Bu e-posta ile kayıt olunamaz",
        icon: Icons.mail_lock_outlined,
        trailing: IconButton(
          icon: const Icon(Icons.settings_backup_restore, color: Colors.greenAccent, size: 20),
          onPressed: () => _confirmAction(
            title: "Engeli Kaldır",
            content: "$email adresinin engeli kaldırılsın mı?",
            actionText: "Engeli Kaldır",
            actionColor: Colors.green,
            onConfirm: () async {
              // 📌 Burası servise bağlanıyor
              final success = await _adminService.unblockEmail(email, widget.currentUser.email);
              if (success) {
                _loadAll(); // Listeyi yenile
              }
            },
          ),
          tooltip: "Engeli Kaldır",
        ),
      );
    },
  );
}

  Widget _adminListItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: purpleColor.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: purpleColor, size: 20),
        ),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 11)),
        trailing: trailing,
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: "Kullanıcı veya video ara...",
        hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
        filled: true,
        fillColor: cardColor,
        prefixIcon: Icon(Icons.search, color: purpleColor),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, int count) {
    return Row(
      children: [
        Icon(icon, color: purpleColor, size: 18),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const Spacer(),
        Text("$count", style: TextStyle(color: purpleColor, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _emptyState(String message) {
    return Center(child: Text(message, style: const TextStyle(color: Colors.white24, fontSize: 13)));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}