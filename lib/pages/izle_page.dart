import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loopin/models/yorum_model.dart';
import 'package:loopin/services/yorum_service.dart';
import 'package:video_player/video_player.dart';
import '../models/video_model.dart';
import '../models/user_model.dart';
import '../models/abonelik_model.dart';
import '../models/begenme_model.dart';
import '../services/abonelik_service.dart';
import '../services/begenme_service.dart';
import '../services/video_service.dart';
import 'videolarim_page.dart';

class IzlePage extends StatefulWidget {
  final VideoModel video;
  final UserModel? currentUser;

  const IzlePage({super.key, required this.video, this.currentUser});

  @override
  State<IzlePage> createState() => _IzlePageState();
}

class _IzlePageState extends State<IzlePage> {
  late VideoPlayerController _controller;
  final AbonelikService _abonelikService = AbonelikService();
  final BegenmeService _begenmeService = BegenmeService();
  final VideoService _videoService = VideoService();

  bool _isInitialized = false;
  bool _isFullScreen = false;
  bool _isSubscribed = false;
  bool _isLiked = false;
  bool _isLoadingSubscription = false;

  int _aboneSayisi = 0;
  int _likeSayisi = 0;
  int _izlenmeSayisi = 0;

  final TextEditingController _commentController = TextEditingController();

  final Color bgColor = const Color(0xFF0F0F14);
  final Color cardColor = const Color(0xFF1A1A22);
  final Color purpleColor = const Color(0xFF5E5CE6);

  @override
  void initState() {
    super.initState();

    _aboneSayisi = widget.video.aboneSayisi;
    _likeSayisi = widget.video.likeSayisi;
    _izlenmeSayisi = widget.video.izlenmeSayisi;

    _videoHazirla();
    _loadInitialData();
    _izlenmeArtir();
    _yorumlariYukle();
  }

  Future<void> _izlenmeArtir() async {
    try {
      final yeniSayi = await _videoService.izlenmeArtir(
        widget.video.id,
        userId: widget.currentUser?.id,
      );
      if (mounted && yeniSayi != null) {
        setState(() {
          _izlenmeSayisi = yeniSayi;
        });
      }
    } catch (e) {
      print("İzlenme artırılamadı: $e");
    }
  }

  Future<void> _loadInitialData() async {
    if (widget.currentUser != null) {
      final subData = await _abonelikService.checkSubscriptionStatus(
        widget.currentUser!.id,
        widget.video.kullaniciId,
      );

      final likeData = await _begenmeService.checkLikeStatus(
        widget.currentUser!.id,
        widget.video.id,
      );

      if (mounted) {
        setState(() {
          _isSubscribed = subData['isSubscribed'] ?? false;
          _aboneSayisi = subData['subscriberCount'] ?? 0;
          _isLiked = likeData ?? false;
        });
      }
    }
  }

  void _likeTetikle() async {
    if (widget.currentUser == null) {
      _showError("Beğenmek için giriş yapmalısınız.");
      return;
    }

    final model = BegenmeModel(
      kullaniciId: widget.currentUser!.id,
      videoId: widget.video.id,
    );

    final result = await _begenmeService.toggleLike(model);

    if (result != null && mounted) {
      setState(() {
        _isLiked = (result['status'] == "liked");
        _likeSayisi = result['currentLikes'];
      });
    }
  }

  void _aboneOlTetikle() async {
    if (widget.currentUser == null) {
      _showError("Abonelik için giriş yapmalısınız.");
      return;
    }

    setState(() => _isLoadingSubscription = true);
    final model = AbonelikModel(
      aboneOlanId: widget.currentUser!.id,
      aboneOlunanId: widget.video.kullaniciId,
    );

    final result = await _abonelikService.toggleSubscription(model);

    if (result != null && mounted) {
      setState(() {
        _isSubscribed = (result['status'] == "subscribed");
        _aboneSayisi = result['currentSubscriberCount'];
      });
    }
    if (mounted) setState(() => _isLoadingSubscription = false);
  }

  void _videoHazirla() async {
    _controller =
        VideoPlayerController.networkUrl(
            Uri.parse("${_videoService.apiBaseUrl}${widget.video.videoUrl}"),
          )
          ..initialize().then((_) {
            if (mounted) {
              setState(() {
                _isInitialized = true;
              });
            }
          });

    _controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
      if (_isFullScreen) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      } else {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      }
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _controller.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isFullScreen) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: _buildVideoPlayerSection()),
      );
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildVideoPlayerSection(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.video.baslik,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _buildLikeButton(),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "$_izlenmeSayisi Görüntüleme",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                  const Divider(color: Colors.white10, height: 32),
                  _buildChannelSection(),
                  const SizedBox(height: 20),
                  _buildDescription(),
                  const Divider(color: Colors.white10, height: 40),
                  _buildCommentsSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLikeButton() {
    return Column(
      children: [
        IconButton(
          icon: Icon(
            _isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
            color: _isLiked ? purpleColor : Colors.white,
          ),
          onPressed: _likeTetikle,
        ),
        Text(
          "$_likeSayisi",
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildChannelSection() {
    final bool isMyVideo = widget.currentUser?.id == widget.video.kullaniciId;
    
    return InkWell(
      onTap: () {
        // Kanal profiline git
        final channelUser = UserModel(
          id: widget.video.kullaniciId,
          kullaniciAdi: widget.video.kullaniciAdi,
          email: '',
          emailOnayli: false,
          aboneSayisi: _aboneSayisi,
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideolarimPage(
              currentUser: channelUser,
              loggedInUser: widget.currentUser, // Mevcut login olan kullanıcı
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: purpleColor.withOpacity(0.2),
              child: Icon(Icons.person, color: purpleColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.video.kullaniciAdi,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    "$_aboneSayisi Abone",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (!isMyVideo)
              ElevatedButton(
                onPressed: _isLoadingSubscription ? null : _aboneOlTetikle,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isSubscribed ? Colors.white10 : Colors.white,
                  foregroundColor: _isSubscribed ? Colors.white : Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: _isLoadingSubscription
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_isSubscribed ? "Abonelikten Çık" : "Abone Ol"),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescription() {
    return Container(
      padding: const EdgeInsets.all(12),
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        widget.video.aciklama,
        style: const TextStyle(color: Colors.white70, fontSize: 13),
      ),
    );
  }

  Widget _buildVideoPlayerSection() {
    return AspectRatio(
      aspectRatio: _isFullScreen
          ? MediaQuery.of(context).size.aspectRatio
          : 16 / 9,
      child: Container(
        color: Colors.black,
        child: _isInitialized
            ? Stack(
                alignment: Alignment.center,
                children: [
                  VideoPlayer(_controller),
                  _VideoOverlayControls(
                    controller: _controller,
                    onToggleFullScreen: _toggleFullScreen,
                    isFullScreen: _isFullScreen,
                    purpleColor: purpleColor,
                  ),
                ],
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  final YorumService _yorumService = YorumService();
  List<YorumModel> _yorumlar = [];

  Future<void> _yorumlariYukle() async {
    try {
      final yorumlar = await _yorumService.yorumlariGetir(widget.video.id);
      if (mounted) {
        setState(() {
          _yorumlar = yorumlar;
        });
      }
    } catch (e) {
      print("Yorumlar yüklenemedi: $e");
    }
  }

  Future<void> _yorumEkle() async {
    if (widget.currentUser == null) {
      _showError("Yorum yapmak için giriş yapmalısınız.");
      return;
    }
    if (_commentController.text.trim().isEmpty) return;

    final yeniYorum = YorumModel(
      id: 0,
      icerik: _commentController.text.trim(),
      tarih: DateTime.now(),
      kullaniciId: widget.currentUser!.id,
      kullaniciAdi: widget.currentUser!.kullaniciAdi,
      videoId: widget.video.id,
    );

    final success = await _yorumService.yorumEkle(yeniYorum);
    if (success) {
      _commentController.clear();
      _yorumlariYukle();
    }
  }

  Future<void> _yorumSil(int yorumId) async {
    if (widget.currentUser == null) return;
    final success = await _yorumService.yorumSil(
      yorumId,
      widget.currentUser!.id,
    );
    if (success) {
      _yorumlariYukle();
    }
  }

  Widget _buildCommentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Yorumlar",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 15),
        TextField(
          controller: _commentController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Yorum ekle...",
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide.none,
            ),
            suffixIcon: IconButton(
              icon: Icon(Icons.send, color: purpleColor),
              onPressed: _yorumEkle,
            ),
          ),
        ),
        const SizedBox(height: 20),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _yorumlar.length,
          separatorBuilder: (_, __) => const Divider(color: Colors.white10),
          itemBuilder: (context, index) {
            final yorum = _yorumlar[index];
            final isMyComment = widget.currentUser?.id == yorum.kullaniciId;
            return ListTile(
              title: Text(
                yorum.kullaniciAdi,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                yorum.icerik,
                style: const TextStyle(color: Colors.white70),
              ),
              trailing: isMyComment
                  ? IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () => _yorumSil(yorum.id),
                    )
                  : null,
            );
          },
        ),
      ],
    );
  }
}

class _VideoOverlayControls extends StatefulWidget {
  final VideoPlayerController controller;
  final VoidCallback onToggleFullScreen;
  final bool isFullScreen;
  final Color purpleColor;

  const _VideoOverlayControls({
    required this.controller,
    required this.onToggleFullScreen,
    required this.isFullScreen,
    required this.purpleColor,
  });

  @override
  State<_VideoOverlayControls> createState() => _VideoOverlayControlsState();
}

class _VideoOverlayControlsState extends State<_VideoOverlayControls> {
  bool _showControls = true;
  double _playbackSpeed = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _showControls = !_showControls),
      behavior: HitTestBehavior.opaque,
      child: AnimatedOpacity(
        opacity: _showControls ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          color: Colors.black45,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  PopupMenuButton<double>(
                    initialValue: _playbackSpeed,
                    icon: const Icon(Icons.speed, color: Colors.white),
                    onSelected: (speed) {
                      setState(() {
                        _playbackSpeed = speed;
                        widget.controller.setPlaybackSpeed(speed);
                      });
                    },
                    itemBuilder: (context) => [0.5, 1.0, 1.5, 2.0]
                        .map(
                          (s) => PopupMenuItem(value: s, child: Text("${s}x")),
                        )
                        .toList(),
                  ),
                ],
              ),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.replay_10,
                        color: Colors.white,
                        size: 40,
                      ),
                      onPressed: () {
                        final newPos =
                            widget.controller.value.position -
                            const Duration(seconds: 10);
                        widget.controller.seekTo(newPos);
                      },
                    ),
                    const SizedBox(width: 20),
                    IconButton(
                      iconSize: 64,
                      icon: Icon(
                        widget.controller.value.isPlaying
                            ? Icons.pause_circle
                            : Icons.play_circle,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          if (widget.controller.value.isPlaying) {
                            widget.controller.pause();
                          } else {
                            widget.controller.play();
                          }
                        });
                      },
                    ),
                    const SizedBox(width: 20),
                    IconButton(
                      icon: const Icon(
                        Icons.forward_10,
                        color: Colors.white,
                        size: 40,
                      ),
                      onPressed: () {
                        final newPos =
                            widget.controller.value.position +
                            const Duration(seconds: 10);
                        widget.controller.seekTo(newPos);
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                child: Column(
                  children: [
                    VideoProgressIndicator(
                      widget.controller,
                      allowScrubbing: true,
                      colors: VideoProgressColors(
                        playedColor: widget.purpleColor,
                        bufferedColor: Colors.white24,
                        backgroundColor: Colors.white12,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            widget.controller.value.volume == 0
                                ? Icons.volume_off
                                : Icons.volume_up,
                            color: Colors.white,
                            size: 22,
                          ),
                          onPressed: () => setState(() {
                            widget.controller.setVolume(
                              widget.controller.value.volume == 0 ? 1.0 : 0.0,
                            );
                          }),
                        ),
                        SizedBox(
                          width: 80,
                          child: Slider(
                            activeColor: widget.purpleColor,
                            inactiveColor: Colors.white24,
                            value: widget.controller.value.volume,
                            onChanged: (vol) => setState(
                              () => widget.controller.setVolume(vol),
                            ),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(
                            widget.isFullScreen
                                ? Icons.fullscreen_exit
                                : Icons.fullscreen,
                            color: Colors.white,
                          ),
                          onPressed: widget.onToggleFullScreen,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
