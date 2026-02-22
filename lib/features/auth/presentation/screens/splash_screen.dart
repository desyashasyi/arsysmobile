import 'package:flutter/material.dart';
import 'package:arsys/features/auth/presentation/screens/login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToLogin();
  }

  void _navigateToLogin() async {
    // Tunggu selama 2 detik
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      // Navigasi ke LoginPage dan hapus splash screen dari tumpukan navigasi
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Di sini Anda bisa menambahkan gambar/logo nanti
            // FlutterLogo(size: 100),
            // SizedBox(height: 24),
            Text(
              'Build by InnoTEC',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
