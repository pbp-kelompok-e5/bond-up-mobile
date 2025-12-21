import 'package:flutter/material.dart';
import 'package:bond_up_mobile/features/event-discovery/screens/event_search_page.dart';
import 'package:bond_up_mobile/features/leaderboard/presentation/screens/leaderboard_screen.dart';
import 'package:bond_up_mobile/core/widgets/navigation/app_drawer.dart';
import 'package:bond_up_mobile/core/theme/app_colors.dart';

import 'event_discovery_page.dart';

class EventDiscoveryHomePage extends StatelessWidget {
  const EventDiscoveryHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. Background Halaman: Dark Gray (Sesuai Event History)
      backgroundColor: AppColors.darkGrayBackground,

      appBar: AppBar(
        backgroundColor: AppColors.deepSea,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        title: const Text(
          "Home",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      drawer: AppDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 2. Greeting Text
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  "Halo, Bonders!\nSiap eksplor hari ini?",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Diubah ke putih agar kontras
                  ),
                ),
              ),

              // 3. Featured Cards Row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildFeaturedCard(
                      context,
                      title: "Cari Partner",
                      subtitle: "Teman olahraga",
                      icon: Icons.emoji_people_outlined,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EventSearchPage())),
                    ),
                    _buildFeaturedCard(
                      context,
                      title: "Cari Event",
                      subtitle: "Temukan keseruan",
                      icon: Icons.search_rounded,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EventSearchPage())),
                    ),
                    _buildFeaturedCard(
                      context,
                      title: "Leaderboard",
                      subtitle: "Cek peringkatmu",
                      icon: Icons.emoji_events_rounded,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LeaderboardScreen())),
                    ),
                  ],
                ),
              ),

              // 4. Label Kategori
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 30, 20, 15),
                child: Text(
                  "Kategori Pilihan",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.orangeSport, // Gunakan aksen orange
                  ),
                ),
              ),

              // 5. Category Icons (Grid Style)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildCategoryIcon(context, "Football", Icons.sports_soccer, 'football'),
                        _buildCategoryIcon(context, "Basketball", Icons.sports_basketball, 'basketball'),
                        _buildCategoryIcon(context, "Badminton", Icons.sports_tennis, 'badminton'),
                        _buildCategoryIcon(context, "Tennis", Icons.sports_tennis, 'tennis'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        _buildCategoryIcon(context, "Running", Icons.directions_run, 'running'),
                        _buildCategoryIcon(context, "Cycling", Icons.directions_bike, 'cycling'),
                        _buildCategoryIcon(context, "Swimming", Icons.pool, 'swimming'),
                        _buildCategoryIcon(context, "Volleyball", Icons.sports_volleyball, 'volleyball'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper untuk Kartu (Warna disesuaikan ke Deep Sea & Teks Putih)
  Widget _buildFeaturedCard(BuildContext context,
      {required String title, required String subtitle, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 15),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.deepSea, // Warna kartu biru gelap
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 40, color: AppColors.orangeSport), // Icon orange sport
            const SizedBox(height: 15),
            Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)
            ),
            Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Colors.white70)
            ),
          ],
        ),
      ),
    );
  }

  /// Helper untuk Icon Kategori (Bulatan Deep Sea dengan Icon Orange)
  Widget _buildCategoryIcon(BuildContext context, String label, IconData icon, String sportKey) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDiscoveryScreen(initialSport: sportKey),
          ),
        );
      },
      child: SizedBox(
        width: 90,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.deepSea, // Background bulat biru gelap
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child:  Icon(icon, color: AppColors.orangeSport, size: 30),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}