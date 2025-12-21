import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// --- IMPORTS ---
import 'package:bond_up_mobile/core/theme/app_colors.dart';
import 'package:bond_up_mobile/features/auth/data/services/auth_service.dart';
import 'package:bond_up_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:bond_up_mobile/features/home/presentation/screens/home_page.dart';

/// Splash screen that checks authentication status on app startup
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Wait a bit for splash screen effect (min 2 seconds)
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final authService = context.read<AuthService>();

    // Check if user is logged in
    // Note: Pastikan authService.isLoggedIn() menghandle pengecekan token/session
    final isLoggedIn = await authService.isLoggedIn();

    if (!mounted) return;

    if (isLoggedIn) {
      // User is logged in, navigate to home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MyHomePage(title: 'BondUp Mobile'),
        ),
      );
    } else {
      // User is not logged in, navigate to login
      // Menggunakan PageRouteBuilder agar transisi Hero logo terlihat smooth
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 800),
          pageBuilder: (_, __, ___) => const LoginScreen(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Tidak perlu backgroundColor karena tertutup Container gradient
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.deepSea,       // #00063D
              AppColors.deepSeaLighter,// #2A2F6C
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // --- 1. APP LOGO ---
            // Menggunakan Hero agar animasi transisi ke Login Screen terlihat keren
            Hero(
              tag: 'app_logo',
              child: Image.asset(
                'assets/images/logo_bondup.png',
                width: 120, // Ukuran sedikit lebih besar di splash
                height: 120,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.sports_handball_rounded,
                    size: 100,
                    color: AppColors.orangeSport,
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            
            // --- 2. APP NAME ---
            Text(
              'BondUp',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
            ),
            const SizedBox(height: 8),
            
            // --- 3. TAGLINE ---
            Text(
              'Find Your Sports Partner',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.white.withValues(alpha: 0.8),
                    fontSize: 16,
                    letterSpacing: 0.5,
                  ),
            ),
            const SizedBox(height: 64),
            
            // --- 4. LOADING INDICATOR ---
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.orangeSport),
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}