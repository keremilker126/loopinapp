import 'package:flutter/material.dart';
import '../services/auth_service.dart'; // AuthService'i import etmeyi unutma
import '../models/user_model.dart';

class ChangePasswordPage extends StatefulWidget {
  final UserModel user; // Hangi kullanıcının şifresini değiştireceğimizi bilmeliyiz

  const ChangePasswordPage({super.key, required this.user});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _authService = AuthService();
  final _currentPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();
  
  bool _isLoading = false;
  String? _errorMessage;

  // --- LOOPIN TEMA RENKLERİ ---
  final Color bgColor = const Color(0xFF0F0F14);      
  final Color cardColor = const Color(0xFF1A1A22);    
  final Color purpleColor = const Color(0xFF5E5CE6);

  void _updatePassword() async {
    final current = _currentPassController.text.trim();
    final yeni = _newPassController.text.trim();
    final tekrar = _confirmPassController.text.trim();

    // 1. Basit Validasyonlar
    if (current.isEmpty || yeni.isEmpty || tekrar.isEmpty) {
      setState(() => _errorMessage = "Lütfen tüm alanları doldurun.");
      return;
    }

    if (yeni != tekrar) {
      setState(() => _errorMessage = "Yeni şifreler birbiriyle eşleşmiyor.");
      return;
    }

    if (yeni.length < 6) {
      setState(() => _errorMessage = "Yeni şifre en az 6 karakter olmalıdır.");
      return;
    }

    setState(() { _isLoading = true; _errorMessage = null; });

    // 2. API Çağrısı
    final result = await _authService.changePassword(
      widget.user.email, // UserModel'den gelen mail
      current, 
      yeni
    );

    setState(() => _isLoading = false);
    
    // 3. Sonuç Yönetimi
    if (result["success"]) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green, 
            content: Text(result["message"] ?? "Şifreniz güncellendi."),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context); // İşlem başarılıysa geri dön
      }
    } else {
      setState(() => _errorMessage = result["message"]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: purpleColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Şifre Değiştir", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: purpleColor.withOpacity(0.1)),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // İkon Tasarımı
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(color: purpleColor.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(Icons.lock_reset_rounded, color: purpleColor, size: 40),
                ),
                const SizedBox(height: 20),
                const Text("Yeni Şifre Belirle", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 8),
                Text(
                  "Hesap: ${widget.user.email}",
                  style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
                ),
                const SizedBox(height: 30),

                if (_errorMessage != null) _errorBox(_errorMessage!),

                _modernInput(_currentPassController, "Mevcut Şifre", Icons.lock_outline, isPass: true),
                const SizedBox(height: 20),
                _modernInput(_newPassController, "Yeni Şifre", Icons.vpn_key_outlined, isPass: true),
                const SizedBox(height: 20),
                _modernInput(_confirmPassController, "Yeni Şifre (Tekrar)", Icons.verified_user_outlined, isPass: true),
                
                const SizedBox(height: 35),

                _isLoading 
                  ? CircularProgressIndicator(color: purpleColor)
                  : _modernBtn("Güncelle ve Kaydet", _updatePassword),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- YARDIMCI WIDGETLAR (UI Tutarlılığı için) ---

  Widget _modernInput(TextEditingController ctrl, String label, IconData icon, {bool isPass = false}) {
    return TextField(
      controller: ctrl,
      obscureText: isPass,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14),
        filled: true,
        fillColor: bgColor.withOpacity(0.5),
        prefixIcon: Icon(icon, color: purpleColor, size: 20),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.white.withOpacity(0.05))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: purpleColor, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      ),
    );
  }

  Widget _modernBtn(String text, VoidCallback onPress) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: onPress,
        style: ElevatedButton.styleFrom(
          backgroundColor: purpleColor,
          foregroundColor: Colors.white,
          elevation: 5,
          shadowColor: purpleColor.withOpacity(0.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _errorBox(String msg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.redAccent.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(msg, style: const TextStyle(color: Colors.redAccent, fontSize: 13))),
        ],
      ),
    );
  }
}