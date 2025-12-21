import 'package:flutter/material.dart';
import 'package:bond_up_mobile/features/event-discovery/screens/event_search_page.dart'; //
import 'package:bond_up_mobile/features/leaderboard/presentation/screens/leaderboard_screen.dart'; //
import 'package:bond_up_mobile/core/widgets/navigation/app_drawer.dart';
import 'package:bond_up_mobile/core/theme/app_colors.dart';

import 'event_discovery_page.dart';

class EventDiscoveryHomePage extends StatelessWidget {
  const EventDiscoveryHomePage({super.key}); //

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // UBAH WARNA DI SINI:
        // Gunakan warna primary agar lebih tegas sebagai background
        backgroundColor: Theme.of(context).colorScheme.primary,
        // foregroundColor memaksa semua text dan icon di AppBar (termasuk drawer) menjadi Putih
        foregroundColor: Colors.white,
        title: const Text("Home"),
      ),
      backgroundColor: Colors.white,
      drawer: AppDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Greeting Text
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  "Halo, Bonders!\nSiap eksplor hari ini?",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.orangeSport,
                  ),
                ),
              ),

              // 2. Row of 3 scrollable tap-able card (Manual Navigation)
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
                      color: Colors.redAccent,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EventSearchPage())), // Ubah ke Search Partner
                    ),
                    _buildFeaturedCard(
                      context,
                      title: "Cari Event",
                      subtitle: "Temukan keseruan",
                      icon: Icons.search_rounded,
                      color: Colors.blueAccent,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EventSearchPage())), //
                    ),
                    _buildFeaturedCard(
                      context,
                      title: "Leaderboard",
                      subtitle: "Cek peringkatmu",
                      icon: Icons.emoji_events_rounded,
                      color: Colors.orangeAccent,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LeaderboardScreen())), //
                    ),
                  ],
                ),
              ),

              // 3. Text Label
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 30, 20, 15),
                child: Text(
                  "Kategori Pilihan",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // 4. 2 Rows of scrollable tap-able cards (Manual Grid Style)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Baris Pertama
                    Row(
                      children: [
                        _buildCategoryIcon(context, "Football", Icons.sports_soccer, Colors.green, 'football'),
                        _buildCategoryIcon(context, "Basketball", Icons.sports_basketball, Colors.orange, 'basketball'),
                        _buildCategoryIcon(context, "Badminton", Icons.sports_tennis, Colors.blue, 'badminton'), // Representasi badminton
                        _buildCategoryIcon(context, "Tennis", Icons.sports_tennis, Colors.lime, 'tennis'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Baris Kedua
                    Row(
                      children: [
                        _buildCategoryIcon(context, "Running", Icons.directions_run, Colors.red, 'running'),
                        _buildCategoryIcon(context, "Cycling", Icons.directions_bike, Colors.cyan, 'cycling'),
                        _buildCategoryIcon(context, "Swimming", Icons.pool, Colors.indigo, 'swimming'),
                        _buildCategoryIcon(context, "Volleyball", Icons.sports_volleyball, Colors.amber, 'volleyball'),
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

  // Widget Helper untuk Kartu Besar (Bagian Atas)
  Widget _buildFeaturedCard(BuildContext context,
      {required String title, required String subtitle, required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 15),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 15),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  // Widget Helper untuk Icon Kategori (Menuju EventDiscoveryScreen dengan Filter)
  Widget _buildCategoryIcon(BuildContext context, String label, IconData icon, Color color, String sportKey) {
    return GestureDetector(
      onTap: () {
        // Navigasi ke EventDiscoveryScreen dengan parameter initialSport
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
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}