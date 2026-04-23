import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/register_model.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _userController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _authService = AuthService();
  
  String? _errorMessage;
  bool _isLoading = false;

  // --- LOOPIN TEMA RENKLERİ (MOR ODAKLI) ---
  final Color bgColor = const Color(0xFF0F0F14);      
  final Color cardColor = const Color(0xFF1A1A22);    
  final Color purpleColor = const Color(0xFF5E5CE6);  // Ana Aksan

  void _register() async {
    final email = _emailController.text.trim();
    final username = _userController.text.trim();
    final password = _passController.text.trim();
    
    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = "Lütfen tüm alanları doldurun.");
      return;
    }

    if (!email.contains("@") || email.length < 5) {
      setState(() => _errorMessage = "Lütfen geçerli bir e-posta adresi girin.");
      return;
    }

    setState(() { _isLoading = true; _errorMessage = null; });

    final model = RegisterModel(
      kullaniciAdi: username,
      email: email,
      sifre: password,
    );
    
    final res = await _authService.register(model);
    
    if (res['message'].toString().contains("başarılı")) {
      if (!mounted) return;
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (c) => AlertDialog(
          backgroundColor: cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: purpleColor.withOpacity(0.2), width: 1)
          ),
          title: Text("Hesap Onayı", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Text(
            "Kaydınız alındı! Hesabınızı aktif etmek için e-posta adresinize gönderdiğimiz onay butonuna tıklayın.",
            style: TextStyle(color: Colors.white.withOpacity(0.7)),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: purpleColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
              ),
              onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
              child: const Text("Giriş Yap", style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      );
    } else {
      setState(() { 
        _errorMessage = res['message']; 
        _isLoading = false; 
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: purpleColor), // Geri butonu mor
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Yeni Hesap Oluştur", style: TextStyle(color: Colors.white, fontSize: 18)),
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
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person_add_outlined, color: purpleColor, size: 50), // İkon mor
                const SizedBox(height: 20),
                const Text(
                  "Loopin'e Katıl",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 10),
                Text(
                  "Video dünyasını keşfetmek için ilk adımı at.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
                ),
                const SizedBox(height: 35),
                
                if (_errorMessage != null) _errorBox(_errorMessage!),

                _modernInput(_userController, "Kullanıcı Adı", Icons.person_outline),
                const SizedBox(height: 20),
                _modernInput(_emailController, "E-posta Adresi", Icons.alternate_email),
                const SizedBox(height: 20),
                _modernInput(_passController, "Şifre", Icons.lock_outline, isPass: true),
                
                const SizedBox(height: 35),
                
                _isLoading 
                  ? CircularProgressIndicator(color: purpleColor) 
                  : _modernBtn("Kayıt Ol ve Mail Gönder", _register),
                
                const SizedBox(height: 20),
                
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Zaten bir hesabın var mı? Giriş Yap",
                    style: TextStyle(color: purpleColor, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _modernInput(TextEditingController ctrl, String label, IconData icon, {bool isPass = false}) {
    return TextField(
      controller: ctrl,
      obscureText: isPass,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14),
        filled: true,
        fillColor: bgColor.withOpacity(0.8),
        prefixIcon: Icon(icon, color: purpleColor, size: 20),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: purpleColor, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      ),
    );
  }

  Widget _modernBtn(String text, VoidCallback onPress) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: onPress,
        style: ElevatedButton.styleFrom(
          backgroundColor: purpleColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 0,
        ),
        child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _errorBox(String msg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 25),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(msg, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}