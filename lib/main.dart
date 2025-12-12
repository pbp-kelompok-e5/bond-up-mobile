import 'package:bond_up_mobile/features/partner_matching/data/model/connection_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:bond_up_mobile/app/app_theme.dart';
import 'package:bond_up_mobile/features/auth/presentation/screens/splash_screen.dart';

import 'features/partner_matching/logic/browse_users_provider.dart';
import 'features/partner_matching/data/datasources/partner_matching_remote_datasource.dart';
import 'features/partner_matching/logic/connections_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(
          create: (_) {
            CookieRequest request = CookieRequest();
            return request;
          },
        ), 

        ChangeNotifierProvider(
          create: (context) {
            final request = context.read<CookieRequest>();
            return BrowseUsersProvider(
              PartnerMatchingRemoteDataSource(request),
            );
          },
        ),

        ChangeNotifierProvider(
          create: (context) {
            final request = context.read<CookieRequest>();
            return ConnectionsProvider(
              PartnerMatchingRemoteDataSource(request)
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