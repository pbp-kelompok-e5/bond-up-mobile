import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:bond_up_mobile/app/app_theme.dart';
import 'package:bond_up_mobile/features/auth/data/services/auth_service.dart';
import 'package:bond_up_mobile/features/auth/presentation/screens/splash_screen.dart';
import 'package:bond_up_mobile/features/partner_matching/logic/browse_users_provider.dart';
import 'package:bond_up_mobile/features/partner_matching/data/services/partner_matching_service.dart';
import 'package:bond_up_mobile/features/partner_matching/logic/connections_provider.dart';

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
        ChangeNotifierProvider(
          create: (context) {
            final request = context.read<CookieRequest>();
            return BrowseUsersProvider(
              PartnerMatchingService(request),
            );
          },
        ),
        ChangeNotifierProvider(
          create: (context) {
            final request = context.read<CookieRequest>();
            return ConnectionsProvider(
              PartnerMatchingService(request)
            );
          },
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
