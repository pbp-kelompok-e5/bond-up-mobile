import 'package:flutter/material.dart';
import 'package:bond_up_mobile/core/design_system.dart';
import 'package:bond_up_mobile/features/profile/data/models/sport_preference_model.dart';

/// Widget Chip reusable untuk menampilkan satu preferensi olahraga.
/// Menggabungkan Emoji Olahraga, Nama Olahraga, dan Level Skill.
class SportPreferenceChip extends StatelessWidget {
  final SportPreferenceModel preference;
  final VoidCallback? onTap;    // Aksi saat chip diklik
  final VoidCallback? onDelete; // Aksi saat tombol hapus (X) diklik

  const SportPreferenceChip({
    super.key,
    required this.preference,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Format Label: "⚽ Football - ⭐️ Intermediate"
    // Kita gunakan string interpolation yang aman
    final String label = '${preference.sportEmoji} ${preference.sportTypeDisplay}  •  ${preference.skillEmoji} ${preference.skillLevelDisplay}';

    return AppChip(
      label: label,
      onTap: onTap,
      onDelete: onDelete,
      // Menggunakan varian 'Secondary' (Outline/Soft) agar tidak terlalu mendominasi
      // jika dibandingkan dengan tombol aksi utama (Connect/Save).
      // Namun jika ingin lebih mencolok, bisa diganti ke ChipVariant.primary.
      variant: ChipVariant.secondary, 
      size: ChipSize.medium,
    );
  }
}

/// Widget Grid/Wrap untuk menampilkan daftar banyak preferensi olahraga.
/// Menangani layout responsif (Wrap) dan tampilan kosong (Empty State).
class SportPreferencesGrid extends StatelessWidget {
  final List<SportPreferenceModel> preferences;
  final Function(SportPreferenceModel)? onTap;
  final Function(SportPreferenceModel)? onDelete;

  const SportPreferencesGrid({
    super.key,
    required this.preferences,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // --- 1. Empty State (Jika tidak ada data) ---
    if (preferences.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ikon Placeholder
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.directions_run_rounded,
                  size: 40,
                  color: AppColors.gray500,
                ),
              ),
              const SizedBox(height: 16),
              
              // Teks Informasi
              const Text(
                'No sport preferences yet',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Add your favorite sports to start matching!',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.gray400,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // --- 2. List Data (Wrap) ---
    // Menggunakan Wrap agar chip otomatis turun ke baris baru jika penuh
    return Wrap(
      spacing: 10,     // Jarak horizontal antar chip
      runSpacing: 10,  // Jarak vertikal antar baris chip
      children: preferences.map((preference) {
        return SportPreferenceChip(
          preference: preference,
          onTap: onTap != null ? () => onTap!(preference) : null,
          onDelete: onDelete != null ? () => onDelete!(preference) : null,
        );
      }).toList(),
    );
  }
}