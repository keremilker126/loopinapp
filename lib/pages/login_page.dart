import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/login_model.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _codeController = TextEditingController();
  final _authService = AuthService();

  bool _isCodeSent = false;
  bool _isLoading = false;
  String? _errorMessage;

  // --- LOOPIN TEMA RENKLERİ ---
  final Color bgColor = const Color(0xFF0F0F14);
  final Color cardColor = const Color(0xFF1A1A22);
  final Color purpleColor = const Color(0xFF5E5CE6);

  // --- GİRİŞ FONKSİYONLARI ---

  void _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() => _errorMessage = "Lütfen tüm alanları doldurun.");
      return;
    }
    setState(() { _isLoading = true; _errorMessage = null; });

    final res = await _authService.login(
      LoginModel(
        email: _emailController.text.trim(),
        sifre: _passwordController.text.trim(),
      ),
    );

    if (res['success'] == true) {
      setState(() { _isCodeSent = true; _isLoading = false; });
    } else {
      setState(() {
        _errorMessage = res['message'];
        _isLoading = false;
        _isCodeSent = false;
      });
    }
  }

  void _verify() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;

    setState(() => _isLoading = true);
    final user = await _authService.verifyLogin(code);

    if (user != null) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home', arguments: user);
    } else {
      setState(() {
        _errorMessage = "Girdiğiniz kod hatalı veya süresi dolmuş!";
        _isLoading = false;
      });
    }
  }

  // --- ŞİFRE SIFIRLAMA ADIMLARI (ONAY KODLU) ---

  // ADIM 1: E-posta kontrolü ve Kod Gönderme
  void _showForgotPasswordStep1() {
    final resetEmailController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Şifremi Sıfırla", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "E-posta adresinizi girin. Sistemde kayıtlıysa size bir onay kodu göndereceğiz.",
              style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
            ),
            const SizedBox(height: 20),
            _modernInput(resetEmailController, "E-posta", Icons.email_outlined),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Vazgeç", style: TextStyle(color: Colors.white.withOpacity(0.5))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: purpleColor),
            onPressed: () async {
              final email = resetEmailController.text.trim();
              if (email.isEmpty) return;

              final res = await _authService.forgotPasswordStep1(email);

              if (mounted) {
                if (res['success'] == true) {
                  Navigator.pop(context); // İlk popup'ı kapat
                  _showForgotPasswordStep2(email); // İkinciyi aç
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(res['message'] ?? "E-posta bulunamadı!"),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              }
            },
            child: const Text("Kod Gönder", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ADIM 2: Gelen Kod ve Yeni Şifre ile Güncelleme
  void _showForgotPasswordStep2(String email) {
    final resetCodeController = TextEditingController();
    final newPasswordController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Yeni Şifre Belirle", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "$email adresine gönderilen kodu ve yeni şifrenizi girin.",
              style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
            ),
            const SizedBox(height: 20),
            _modernInput(resetCodeController, "Onay Kodu", Icons.security),
            const SizedBox(height: 15),
            _modernInput(newPasswordController, "Yeni Şifre", Icons.lock_reset, isPass: true),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("İptal", style: TextStyle(color: Colors.white.withOpacity(0.5))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () async {
              final code = resetCodeController.text.trim();
              final newPass = newPasswordController.text.trim();
              if (code.isEmpty || newPass.isEmpty) return;

              final res = await _authService.forgotPasswordStep2(email, code, newPass);

              if (mounted) {
                if (res['success'] == true) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Şifreniz başarıyla güncellendi."),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(res['message'] ?? "Kod hatalı!"),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              }
            },
            child: const Text("Şifreyi Güncelle", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_circle_fill, color: purpleColor, size: 45),
                    const SizedBox(width: 12),
                    const Text(
                      "Loopin",
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _isCodeSent ? "Güvenlik Kodunu Girin" : "Modern Video Platformu",
                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
                ),
                const SizedBox(height: 35),

                if (_errorMessage != null) _errorBox(_errorMessage!),

                if (!_isCodeSent) ...[
                  _modernInput(_emailController, "E-posta", Icons.alternate_email),
                  const SizedBox(height: 20),
                  _modernInput(_passwordController, "Şifre", Icons.lock_outline, isPass: true),
                  
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _showForgotPasswordStep1,
                      child: Text(
                        "Şifremi Unuttum",
                        style: TextStyle(color: purpleColor.withOpacity(0.8), fontSize: 13),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 10),
                  _modernBtn("Giriş Yap", _login, purpleColor),
                ] else ...[
                  _modernInput(_codeController, "6 Haneli Doğrulama Kodu", Icons.security_outlined),
                  const SizedBox(height: 30),
                  _modernBtn("Doğrula ve Giriş Yap", _verify, purpleColor),
                  TextButton(
                    onPressed: () => setState(() => _isCodeSent = false),
                    child: Text(
                      "Geri Dön",
                      style: TextStyle(color: purpleColor.withOpacity(0.7), fontWeight: FontWeight.w500),
                    ),
                  ),
                ],

                const SizedBox(height: 25),
                const Divider(color: Colors.white10, thickness: 1),
                const SizedBox(height: 15),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Henüz üye değil misin?", style: TextStyle(color: Colors.white.withOpacity(0.6))),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/register'),
                      child: Text(
                        "Kayıt Ol",
                        style: TextStyle(color: purpleColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- MODERN COMPONENTLER ---

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

  Widget _modernBtn(String text, VoidCallback onPress, Color color) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: _isLoading
          ? Center(child: CircularProgressIndicator(color: purpleColor))
          : ElevatedButton(
              onPressed: onPress,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
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
          Expanded(child: Text(msg, style: const TextStyle(color: Colors.redAccent, fontSize: 13))),
        ],
      ),
    );
  }
}