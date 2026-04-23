import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';

void main() {
  runApp(const LoopinApp());
}

class LoopinApp extends StatelessWidget {
  const LoopinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Loopin Video',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        useMaterial3: true,
      ),
      // İlk açılacak sayfa giriş sayfası olsun
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}