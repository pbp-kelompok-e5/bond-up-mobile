import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:bond_up_mobile/features/auth/data/services/auth_service.dart';
import 'package:bond_up_mobile/features/auth/presentation/screens/login_screen.dart';
// Pastikan import ini sesuai dengan lokasi file kamu sebenarnya
import 'package:bond_up_mobile/core/design_system.dart'; 
import 'package:bond_up_mobile/core/widgets/navigation/app_drawer.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // --- BAGIAN COUNTER DIHAPUS ---

  Future<void> _handleLogout() async {
    // Mengambil request dari provider
    final request = context.read<CookieRequest>();
    final authService = AuthService(request);

    // Melakukan logout ke backend
    await authService.logout();

    // Cek apakah widget masih aktif sebelum menggunakan context
    if (!mounted) return;

    // Menampilkan pesan sukses
    try {
       // Asumsi kamu punya class ToastUtils di design_system.dart
       ToastUtils.showSuccess(context, 'Logged out successfully');
    } catch (e) {
       // Fallback jika ToastUtils belum siap
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Logged out successfully')),
       );
    }

    // Navigasi kembali ke Login Screen dan menghapus history route sebelumnya
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Drawer dipanggil di sini. Karena warna icon di AppBar sudah diubah jadi putih,
      // icon "hamburger" drawer otomatis akan berwarna putih.
      drawer: const AppDrawer(),
      appBar: AppBar(
        // UBAH WARNA DI SINI:
        // Gunakan warna primary agar lebih tegas sebagai background
        backgroundColor: Theme.of(context).colorScheme.primary,
        // foregroundColor memaksa semua text dan icon di AppBar (termasuk drawer) menjadi Putih
        foregroundColor: Colors.white, 
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            // Aksi saat tombol logout ditekan
            onPressed: _handleLogout,
          ),
        ],
      ),
      // Body diubah menjadi tampilan selamat datang sederhana karena counter dihapus
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             Icon(Icons.home_filled, size: 64, color: Theme.of(context).colorScheme.primary),
             const SizedBox(height: 16),
             Text(
              'Welcome to BondUp!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
             const SizedBox(height: 8),
             const Text('Use the drawer menu to navigate.'),
          ],
        ),
      ),
      // --- FLOATING ACTION BUTTON DIHAPUS ---
    );
  }
}