import 'package:flutter/material.dart';
import 'package:bond_up_mobile/core/design_system.dart';

/// Widget Kartu Statistik User (Points & Events)
/// Menampilkan ringkasan aktivitas user dalam format kartu horizontal.
class UserStatsCard extends StatelessWidget {
  final int totalPoints;
  final int totalEvents;

  const UserStatsCard({
    super.key,
    required this.totalPoints,
    required this.totalEvents,
  });

  @override
  Widget build(BuildContext context) {
    return DeepSeaCard(
      // Menggunakan IntrinsicHeight agar garis pemisah (divider)
      // otomatis mengikuti tinggi konten terpanjang di dalam Row.
      body: IntrinsicHeight(
        child: Row(
          children: [
            // --- BAGIAN POINTS ---
            Expanded(
              child: _StatItem(
                icon: Icons.emoji_events_rounded,
                label: 'Total Points',
                value: totalPoints.toString(),
              ),
            ),
            
            // --- GARIS PEMISAH ---
            VerticalDivider(
              color: AppColors.white.withValues(alpha: 0.1), // Transparan halus
              thickness: 1,
              width: 32, // Memberi jarak horizontal antar item
              indent: 8, // Jarak dari atas
              endIndent: 8, // Jarak dari bawah
            ),

            // --- BAGIAN EVENTS ---
            Expanded(
              child: _StatItem(
                icon: Icons.calendar_month_rounded,
                label: 'Events Joined',
                value: totalEvents.toString(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget internal untuk merender satu item statistik
class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Ikon dengan background lingkaran transparan
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.orangeSport.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 28,
            color: AppColors.orangeSport,
          ),
        ),
        const SizedBox(height: 12),
        
        // Nilai Angka (Besar & Tebal)
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800, // Extra Bold
            color: Colors.white,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 4),
        
        // Label (Kecil & Abu-abu)
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.gray400, // Warna abu terang agar terbaca di dark mode
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}