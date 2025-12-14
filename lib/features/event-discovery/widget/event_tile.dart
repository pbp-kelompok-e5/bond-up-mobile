import 'package:flutter/material.dart';
import 'package:bond_up_mobile/app/app_theme.dart';
import 'package:bond_up_mobile/features/event-discovery/data/models/event_model.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class EventCard extends StatelessWidget {
  final Event event;

  const EventCard({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.secondary,
        borderRadius: BorderRadius.circular(20), // Sudut membulat container utama
      ),
      child: Row(
        children: [
          // 1. BAGIAN GAMBAR (KIRI)
          _buildImageSection(),

          const SizedBox(width: 16), // Spasi antar gambar dan teks

          // 2. BAGIAN INFORMASI (KANAN)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Judul Event
                Text(
                  event.title.toUpperCase(),
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                // Garis Bawah (Divider)
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  height: 2,
                  width: double.infinity,
                  color: colorScheme.primary,
                ),

                // Row untuk Status dan Tanggal
                Row(
                  children: [
                    // Chip Status
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        event.status, // Data status
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Tanggal Event
                    Text(
                      _formatDate(event.eventDate),
                      style: TextStyle(
                          color: colorScheme.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Row untuk Kota
                Row(
                  children: [
                    // Ikon Lokasi (Icons.location_on)
                    Icon(
                      Icons.location_on, // Menggunakan Icons.location_on
                      size: 16,
                      color: colorScheme.primary, // Memberikan warna oranye sesuai desain
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        event.city.toUpperCase(), // Data kota
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Chip Sport Type (Paling bawah)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    event.sportType.toUpperCase(), // Data tipe olahraga
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk menangani Gambar vs Placeholder
  Widget _buildImageSection() {
    bool hasImage = event.thumbnail != null && event.thumbnail!.isNotEmpty;

    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        color: Colors.grey.shade400, // Warna dasar jika gambar loading/error
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        // For Android emulator: http://10.0.2.2:8000
        // For web/Chrome: http://localhost:8000
        // For production: https://farrell-bagoes-sigmaapp.pbp.cs.ui.ac.id
        child: hasImage
            ? Image.network(
          'http://localhost:8000/proxy-image/?url=${Uri.encodeComponent(event.thumbnail ?? '')}',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Fallback jika URL rusak
            return _buildPlaceholderContent();
          },
        )
            : _buildPlaceholderContent(),
      ),
    );
  }

  // Konten Placeholder (Teks "Image")
  Widget _buildPlaceholderContent() {
    return Center(
      child: Icon(Icons.broken_image)
    );
  }

  // Helper simpel untuk format tanggal (Contoh output: 14 - JAN - 2025)
  // Tanpa package intl agar bisa langsung jalan
  String _formatDate(DateTime date) {
    const List<String> months = [
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
    ];

    String day = date.day.toString().padLeft(2, '0');
    String month = months[date.month - 1];
    String year = date.year.toString();

    return "$day - $month - $year";
  }
}