import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:pbp_django_auth/pbp_django_auth.dart';
=======
>>>>>>> 5b6033e392d1d03612b89f4c721dbbe03549a053
import 'package:provider/provider.dart';
import 'package:bond_up_mobile/core/design_system.dart';
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
    // Wait a bit for splash screen effect
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

<<<<<<< HEAD
    final request = context.read<CookieRequest>();
    final authService = AuthService(request);
=======
    final authService = context.read<AuthService>();
>>>>>>> 5b6033e392d1d03612b89f4c721dbbe03549a053

    // Check if user is logged in
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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepSea,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo or Icon
            Icon(
              Icons.sports_tennis,
              size: 100,
              color: AppColors.orangeSport,
            ),
            const SizedBox(height: 24),
            
            // App Name
            Text(
              'BondUp',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            
            // Tagline
            Text(
              'Find Your Sports Partner',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
<<<<<<< HEAD
                    color: AppColors.white.withValues(alpha: 0.8),
=======
<<<<<<< HEAD
                    color: AppColors.white.withOpacity(0.8),
=======
                    color: AppColors.white.withValues(alpha: 0.8),
>>>>>>> 5b6033e392d1d03612b89f4c721dbbe03549a053
>>>>>>> 77207f9affbfcd922331b977912b5085dbe88a19
                  ),
            ),
            const SizedBox(height: 48),
            
            // Loading indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.orangeSport),
            ),
          ],
        ),
      ),
    );
  }
}

