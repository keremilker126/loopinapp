import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/video_service.dart';

class VideoYuklePage extends StatefulWidget {
  final int currentUserId;
  const VideoYuklePage({super.key, required this.currentUserId});

  @override
  State<VideoYuklePage> createState() => _VideoYuklePageState();
}

class _VideoYuklePageState extends State<VideoYuklePage> {
  // Web üzerinde 400 MB makul bir limit, ancak tarayıcı RAM'ine dikkat edilmeli.
  static const int _maxVideoFileSize = 400 * 1024 * 1024; 

  final VideoService _videoService = VideoService();
  final ImagePicker _picker = ImagePicker();

  XFile? _selectedVideo;
  XFile? _selectedImage;
  final TextEditingController _baslikController = TextEditingController();
  final TextEditingController _aciklamaController = TextEditingController();
  
  bool _isUploading = false;

  // Galeriden Video Seç
  Future<void> _pickVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      final int videoSize = await video.length();
      if (videoSize > _maxVideoFileSize) {
        _showSnackBar("Seçilen video 400 MB'den büyük olamaz.", Colors.orangeAccent);
        return;
      }
      setState(() => _selectedVideo = video);
    }
  }

  // Galeriden Kapak Resmi Seç
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _selectedImage = image);
    }
  }

  // Ana Yükleme Fonksiyonu
  Future<void> _yukle() async {
    if (_selectedVideo == null || _selectedImage == null || _baslikController.text.trim().isEmpty) {
      _showSnackBar("Lütfen video, kapak resmi ve başlık alanlarını doldurun!", Colors.redAccent);
      return;
    }

    // Klavyeyi kapat ve yükleme moduna geç
    FocusScope.of(context).unfocus();
    setState(() => _isUploading = true);

    // Web'de UI'ın donmaması için asenkron bir bekleme ekliyoruz
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      final String? error = await _videoService.videoYukle(
        videoFile: _selectedVideo!,
        imageFile: _selectedImage!,
        baslik: _baslikController.text.trim(),
        aciklama: _aciklamaController.text.trim(),
        kullaniciId: widget.currentUserId,
      );

      if (!mounted) return;

      if (error == null) {
        _showSnackBar("✅ Video başarıyla yayınlandı!", Colors.green);
        Navigator.pop(context);
      } else {
        setState(() => _isUploading = false);
        _showErrorDialog(error);
      }
    } catch (e) {
      setState(() => _isUploading = false);
      _showErrorDialog("Beklenmedik bir hata oluştu: $e");
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A22),
        title: const Text("Yükleme Hatası", style: TextStyle(color: Colors.white)),
        content: Text(message, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Tamam", style: TextStyle(color: Colors.purpleAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F14),
      appBar: AppBar(
        title: const Text("Yeni Video Paylaş", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.deepPurpleAccent),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Medya Dosyaları", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _uploadBox(
                        title: _selectedVideo == null ? "Video Seç" : "Video Tamam ✅",
                        subtitle: _selectedVideo?.name ?? "MP4, MOV",
                        icon: Icons.movie_creation_outlined,
                        onTap: _pickVideo,
                        color: Colors.purpleAccent,
                        isSelected: _selectedVideo != null,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _uploadBox(
                        title: _selectedImage == null ? "Kapak Seç" : "Kapak Tamam ✅",
                        subtitle: _selectedImage?.name ?? "JPG, PNG",
                        icon: Icons.image_search_outlined,
                        onTap: _pickImage,
                        color: Colors.blueAccent,
                        isSelected: _selectedImage != null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                const Text("Video Bilgileri", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                TextField(
                  controller: _baslikController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDeco("Video Başlığı (Örn: Muhteşem Manzara)"),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _aciklamaController,
                  maxLines: 4,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDeco("İzleyicilere video hakkında bilgi verin..."),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 8,
                    shadowColor: Colors.deepPurpleAccent.withOpacity(0.4),
                  ),
                  onPressed: _isUploading ? null : _yukle,
                  child: Text(
                    _isUploading ? "DOSYALAR İŞLENİYOR..." : "VİDEOYU YAYINLA",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          if (_isUploading) _uploadingOverlay(),
        ],
      ),
    );
  }

  Widget _uploadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.85),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Colors.deepPurpleAccent, strokeWidth: 3),
              const SizedBox(height: 30),
              const Text(
                'Video Sunucuya Gönderiliyor',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Büyük dosyalarda bu işlem birkaç dakika sürebilir. Lütfen sayfayı kapatmayın.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white60, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _uploadBox({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 140,
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : const Color(0xFF1A1A22),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.white10,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? color : Colors.white38, size: 40),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(color: isSelected ? color : Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
      filled: true,
      fillColor: const Color(0xFF1A1A22),
      contentPadding: const EdgeInsets.all(20),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.white10),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.deepPurpleAccent, width: 2),
      ),
    );
  }
}