import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:bond_up_mobile/core/design_system.dart';
import 'package:bond_up_mobile/features/auth/data/services/auth_service.dart';
import 'package:bond_up_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:bond_up_mobile/features/profile/presentation/screens/profile_screen.dart';
import 'package:bond_up_mobile/features/profile/data/services/profile_service.dart';
import 'package:bond_up_mobile/features/event-discovery/screens/event_dicovery_home_page.dart';
import 'package:bond_up_mobile/features/leaderboard/presentation/screens/leaderboard_screen.dart';
import 'package:bond_up_mobile/features/leaderboard/presentation/screens/points_dashboard_screen.dart';
import 'package:bond_up_mobile/features/event-management/screens/my_events_page.dart';
import 'package:bond_up_mobile/features/event-management/screens/event_history_page.dart';
import 'package:bond_up_mobile/features/partner_matching/presentation/screens/browse_users_screen.dart';

/// App-wide navigation drawer
/// Widget ini adalah menu samping (Drawer) yang muncul di hampir seluruh bagian aplikasi.
/// Desainnya dibuat modern dengan sudut membulat dan latar belakang gradasi gelap.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // Kita butuh 'request' untuk mengecek status login dan mengambil data dari backend Django.
    final request = context.watch<CookieRequest>();

    return Drawer(
      // Memberikan lengkungan di sisi kanan agar drawer tidak terlihat kaku seperti kotak biasa.
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Container(
        // Menggunakan gradasi warna gelap (Deep Sea) untuk memberikan kesan premium dan kedalaman.
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.deepSea,
              Color(0xFF1A2A3A), 
            ],
          ),
        ),
        child: Column(
          children: [
            // Header: Bagian yang menampilkan foto profil dan info dasar user.
            _buildDrawerHeader(context, request),
            
            // Bungkus dengan Expanded agar daftar menu bisa di-scroll jika layar HP kecil.
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                children: [
                  // --- Kategori Menu Umum ---
                  _buildSectionLabel('GENERAL'),
                  _buildModernDrawerItem(
                    context: context,
                    icon: Icons.home_rounded,
                    title: 'Home',
                    onTap: () {
                      Navigator.pop(context); // Tutup drawer dulu sebelum pindah halaman.
                      // Reset navigasi ke Home agar user tidak terjebak dalam tumpukan (stack) halaman.
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EventDiscoveryHomePage(),
                        ),
                        (route) => false,
                      );
                    },
                  ),
                  _buildModernDrawerItem(
                    context: context,
                    icon: Icons.person_rounded,
                    title: 'My Profile',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // --- Kategori Fitur Sosial ---
                  _buildSectionLabel('SOCIAL'),
                  _buildModernDrawerItem(
                    context: context,
                    icon: Icons.calendar_month_rounded,
                    title: 'Manage Events',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const MyEventsPage()));
                    },
                  ),
                  _buildModernDrawerItem(
                    context: context,
                    icon: Icons.history_rounded,
                    title: 'Event History',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const EventHistoryPage()));
                    },
                  ),
                  _buildModernDrawerItem(
                    context: context,
                    icon: Icons.people_alt_rounded,
                    title: 'Find Partners',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const BrowseUsersScreen()));
                    },
                  ),

                  const SizedBox(height: 16),

                  // --- Kategori Kompetisi & Poin ---
                  _buildSectionLabel('COMPETITION'),
                  _buildModernDrawerItem(
                    context: context,
                    icon: Icons.leaderboard_rounded,
                    title: 'Leaderboard',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const LeaderboardScreen()));
                    },
                  ),
                  _buildModernDrawerItem(
                    context: context,
                    icon: Icons.pie_chart_rounded,
                    title: 'Points Dashboard',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const PointsDashboardScreen()));
                    },
                  ),
                ],
              ),
            ),

            // Bagian bawah drawer yang dipisahkan garis tipis, khusus untuk tombol Logout.
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.white10, width: 1),
                ),
              ),
              child: _buildModernDrawerItem(
                context: context,
                icon: Icons.logout_rounded,
                title: 'Logout',
                iconColor: Colors.redAccent,
                textColor: Colors.redAccent,
                backgroundColor: Colors.red.withValues(alpha: 0.1), // Beri warna merah transparan agar terlihat sebagai aksi 'bahaya'.
                onTap: () async => await _handleLogout(context, request),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Membuat teks label kecil berwarna abu-abu untuk mengelompokkan menu.
  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 8, top: 4),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.5),
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  /// Bagian paling atas drawer. Di sini kita memanggil ProfileService secara asinkron.
  /// Ada logika 'loading' untuk menampilkan kotak kosong (skeleton) sebelum data user muncul.
  Widget _buildDrawerHeader(BuildContext context, CookieRequest request) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.deepSea,
        // Efek cahaya halus dari atas ke bawah pada header.
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white.withValues(alpha: 0.05), Colors.transparent],
        ),
        border: const Border(bottom: BorderSide(color: Colors.white10, width: 1)),
      ),
      child: FutureBuilder(
        future: ProfileService(request).getOwnProfile(),
        builder: (context, snapshot) {
          // Siapkan data default jika profil gagal dimuat atau masih loading.
          String displayInitials = "BU";
          String displayUrl = "";
          String displayName = "BondUp User";
          String displayEmail = "Loading...";
          bool isLoading = snapshot.connectionState == ConnectionState.waiting;

          // Jika data berhasil ditarik, timpa nilai default dengan data asli.
          if (snapshot.hasData && snapshot.data != null && snapshot.data!.status) {
            final profile = snapshot.data!.data!;
            displayInitials = profile.initials;
            displayUrl = profile.profileImageUrl;
            displayName = profile.username;
            displayEmail = profile.email;
          }

          return Row(
            children: [
              // Avatar dengan border oranye agar terlihat stand-out.
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.orangeSport, width: 2),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 4)),
                  ],
                ),
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.deepSeaLight,
                  backgroundImage: displayUrl.isNotEmpty ? NetworkImage(displayUrl) : null,
                  // Tampilkan inisial nama jika foto profil tidak tersedia.
                  child: displayUrl.isEmpty ? Text(displayInitials, style: const TextStyle(fontSize: 20, color: AppColors.orangeSport, fontWeight: FontWeight.bold)) : null,
                ),
              ),
              const SizedBox(width: 16),
              // Bagian detail teks user.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Tampilkan kotak skeleton saat loading agar UI tidak kaku.
                    if (isLoading) _buildSkeleton(100, 16) 
                    else Text(displayName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    if (isLoading) _buildSkeleton(140, 12)
                    else if (displayEmail.isNotEmpty) Text(displayEmail, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13), overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Fungsi pembantu untuk membuat item menu yang konsisten (ikon + teks).
  Widget _buildModernDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
    Color? backgroundColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: backgroundColor ?? Colors.transparent,
        leading: Icon(icon, color: iconColor ?? AppColors.orangeSport, size: 22),
        title: Text(title, style: TextStyle(color: textColor ?? Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
        onTap: onTap,
        splashColor: AppColors.orangeSport.withValues(alpha: 0.2),
      ),
    );
  }

  /// Logika Logout: Menggunakan dialog konfirmasi untuk mencegah ketidaksengajaan.
  Future<void> _handleLogout(BuildContext context, CookieRequest request) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E2F3F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout', style: TextStyle(color: Colors.white)),
        content: const Text('Apakah kamu yakin ingin mengakhiri sesi ini?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Ya, Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      Navigator.pop(context); // Tutup drawer.
      final success = await AuthService(request).logout();
      if (context.mounted) {
        if (success) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Berhasil keluar!')));
        // Kembali ke layar login dan hapus semua history halaman sebelumnya.
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
      }
    }
  }

  /// Widget kecil untuk placeholder loading (efek skeleton).
  Widget _buildSkeleton(double width, double height) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
    );
  }
}