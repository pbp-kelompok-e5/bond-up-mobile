import 'package:bond_up_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:bond_up_mobile/app/app_theme.dart';
import 'package:bond_up_mobile/features/auth/data/services/auth_service.dart';
import 'package:bond_up_mobile/features/auth/presentation/screens/splash_screen.dart';

// Kita tidak perlu import MyHomePage di sini kecuali jika ingin testing langsung di home:
// import 'package:bond_up_mobile/features/home/screens/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<CookieRequest>(
          create: (_) {
            CookieRequest request = CookieRequest();
            return request;
          },
        ),
        Provider<AuthService>(
          create: (context) => AuthService(context.read<CookieRequest>()),
        ),
      ],
      child: MaterialApp(
        title: 'BondUp Mobile',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        // Start dari Splash Screen
        home: const SplashScreen(),
      ),
    );
  }
}
