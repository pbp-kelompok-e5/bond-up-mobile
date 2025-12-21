import 'package:flutter/material.dart';
import 'package:bond_up_mobile/core/theme/app_colors.dart';

/// Tipe status yang didukung oleh Badge
enum StatusType { active, cancelled, completed }

/// Widget Badge Status BondUp
/// Digunakan untuk menandai status transaksi, tiket, atau item list.
/// Desain mengacu pada .status-badge di global CSS.
class StatusBadge extends StatelessWidget {
  final StatusType status;
  final String? customLabel; // Label opsional jika ingin menimpa teks default

  const StatusBadge({
    super.key,
    required this.status,
    this.customLabel,
  });

  @override
  Widget build(BuildContext context) {
    // Mengambil warna tema berdasarkan status saat ini
    final Color mainColor = _getBorderColor();
    final Color backgroundColor = _getBackgroundColor();

    return Container(
      // Padding horizontal sedikit lebih lebar agar teks 'bernafas'
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(
          color: mainColor,
          width: 1, // Border tipis untuk definisi batas yang rapi
        ),
        borderRadius: BorderRadius.circular(12), // Radius rounded
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Agar lebar container mengikuti konten
        crossAxisAlignment: CrossAxisAlignment.center, // Sentralisasi vertikal
        children: [
          // 1. Indikator Dot (Titik)
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: mainColor, // Warna dot mengikuti warna border/teks
              shape: BoxShape.circle,
            ),
          ),
          
          const SizedBox(width: 6), // Jarak antara dot dan teks
          
          // 2. Label Teks
          Text(
            // Logika: Gunakan customLabel jika ada, jika tidak gunakan default.
            // Selalu di-uppercase agar konsisten dengan gaya desain Badge.
            (customLabel ?? _getLabel()).toUpperCase(),
            style: TextStyle(
              color: mainColor,
              fontSize: 11, // Ukuran 11-12 ideal untuk badge/tag
              fontWeight: FontWeight.w700, // Bold agar terbaca jelas meski kecil
              letterSpacing: 0.5, // Sedikit spasi agar tidak terlalu padat
              height: 1.2, // Mengatur line-height agar center secara optik
            ),
          ),
        ],
      ),
    );
  }

  /// Mendapatkan teks default berdasarkan tipe status
  String _getLabel() {
    switch (status) {
      case StatusType.active:
        return 'Active';
      case StatusType.cancelled:
        return 'Cancelled';
      case StatusType.completed:
        return 'Completed';
    }
  }

  /// Mendapatkan warna background (biasanya warna soft/pastel)
  Color _getBackgroundColor() {
    switch (status) {
      case StatusType.active:
        return AppColors.statusActiveBackground;
      case StatusType.cancelled:
        return AppColors.statusCancelledBackground;
      case StatusType.completed:
        return AppColors.statusCompletedBackground;
    }
  }

  /// Mendapatkan warna utama (border, dot, dan teks)
  Color _getBorderColor() {
    switch (status) {
      case StatusType.active:
        return AppColors.statusActive;
      case StatusType.cancelled:
        return AppColors.statusCancelled;
      case StatusType.completed:
        return AppColors.statusCompleted;
    }
  }
}