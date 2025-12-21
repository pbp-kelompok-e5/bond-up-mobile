import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

// Pastikan import ini sesuai dengan project Anda
import 'package:bond_up_mobile/core/theme/app_colors.dart';
import '../services/event_history_service.dart';
import '../models/event_with_status.dart';
import '../models/event.dart';
import 'event_detail_page.dart';
import '../../reviews/presentation/screens/event_reviews_screen.dart';

/// Halaman Riwayat Acara (Event History).
/// 
/// Menampilkan daftar acara yang pernah diikuti pengguna.
/// Menggunakan kombinasi warna Background Abu-abu Gelap dan Kartu Biru Gelap (Deep Sea).
class EventHistoryPage extends StatefulWidget {
  const EventHistoryPage({super.key});
  
  @override
  State<EventHistoryPage> createState() => _EventHistoryPageState();
}

class _EventHistoryPageState extends State<EventHistoryPage> {
  late EventHistoryService service;
  List<EventWithStatus> eventsWithStatus = [];
  bool isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final request = context.watch<CookieRequest>();
    service = EventHistoryService(request);
    
    // Muat data hanya jika list kosong dan masih loading
    if (isLoading && eventsWithStatus.isEmpty) {
      _fetchEventHistory();
    }
  }

  /// Mengambil data dari API
  Future<void> _fetchEventHistory() async {
    setState(() => isLoading = true);
    try {
      final events = await service.fetchEventHistory();
      if (mounted) {
        setState(() {
          eventsWithStatus = events;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray50,  
      
      appBar: AppBar(
        title: const Text(
          'Event History',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        // AppBar menyatu dengan background halaman
        backgroundColor: AppColors.darkGrayBackground,  
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: "Refresh Data",
            onPressed: _fetchEventHistory,
          ),
        ],
      ),
      
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.orangeSport),
            )
          : eventsWithStatus.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  color: AppColors.orangeSport,
                  backgroundColor: AppColors.deepSea,
                  onRefresh: _fetchEventHistory,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: eventsWithStatus.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 20),
                    itemBuilder: (context, index) {
                      return _buildEventCard(eventsWithStatus[index]);
                    },
                  ),
                ),
    );
  }

  /// Tampilan Kosong (Empty State)
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              // Background icon menggunakan Deep Sea agar kontras dengan Dark Gray
              color: AppColors.deepSea,  
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.history_toggle_off_rounded,
              size: 64,
              color: AppColors.orangeSport,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "No Event History",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "You haven't joined any events yet.",
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  /// Membangun Kartu Event
  Widget _buildEventCard(EventWithStatus eventWithStatus) {
    final event = eventWithStatus.event;
    final status = eventWithStatus.participantStatus;

    return Container(
      decoration: BoxDecoration(
        // 2. Warna Kartu: Deep Sea (Biru Gelap)
        color: AppColors.deepSea,  
        borderRadius: BorderRadius.circular(16),
        // Bayangan untuk memisahkan kartu dari background abu-abu
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- GAMBAR & BADGE STATUS ---
          Stack(
            children: [
              // Gambar Event
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: SizedBox(
                  height: 160,
                  width: double.infinity,
                  child: event.thumbnail.isNotEmpty
                      ? Image.network(
                          event.thumbnail,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.white10,
                            child: const Icon(Icons.image_not_supported, color: Colors.white24, size: 40),
                          ),
                        )
                      : Container(
                          // Placeholder jika gambar kosong
                          color: AppColors.orangeSport.withValues(alpha: 0.1),
                          child: const Icon(Icons.sports_soccer, color: AppColors.orangeSport, size: 40),
                        ),
                ),
              ),
              
              // Gradient Overlay (Supaya teks status terbaca jelas)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.7),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.4],
                    ),
                  ),
                ),
              ),

              // Status Badge (Melayang di kanan atas)
              Positioned(
                top: 12,
                right: 12,
                child: _buildStatusBadge(status),
              ),
            ],
          ),

          // --- KONTEN INFORMASI ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Judul Event
                Text(
                  event.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Teks putih di atas kartu biru gelap
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // Tanggal
                Row(
                  children: [
                    const Icon(Icons.calendar_month_rounded, size: 16, color: AppColors.orangeSport),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('EEE, d MMMM yyyy').format(event.eventDate),
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Lokasi
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded, size: 16, color: AppColors.orangeSport),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${event.locationName}, ${event.city}',
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Garis pemisah tipis
                Divider(height: 1, color: Colors.white.withValues(alpha: 0.1)),
                const SizedBox(height: 16),

                // Tombol Aksi
                SizedBox(
                  width: double.infinity,
                  child: _buildActionButton(event, status),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Widget Badge Status (Pill Shape)
  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor = Colors.white;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'attended':
        bgColor = AppColors.statusCompleted; // Hijau/Biru
        icon = Icons.check_circle_rounded;
        break;
      case 'joined':
        bgColor = AppColors.statusActive; // Hijau
        icon = Icons.confirmation_number_rounded;
        break;
      case 'cancelled':
        bgColor = AppColors.buttonDanger; // Merah
        icon = Icons.cancel_rounded;
        break;
      default:
        bgColor = Colors.grey;
        icon = Icons.info_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 10,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Widget Tombol Aksi (Dinamis berdasarkan status)
  Widget _buildActionButton(Event event, String status) {
    // Style dasar tombol
    final btnStyle = ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
    );

    switch (status.toLowerCase()) {
      case 'attended':
        return ElevatedButton.icon(
          icon: const Icon(Icons.rate_review_rounded, size: 18),
          label: const Text("Write Review"),
          style: btnStyle.copyWith(
            backgroundColor: WidgetStateProperty.all(AppColors.orangeSport),
            foregroundColor: WidgetStateProperty.all(Colors.white),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EventReviewsPage(
                  eventId: event.id,
                  eventTitle: event.title,
                ),
              ),
            );
          },
        );

      case 'joined':
        // Tombol View Details dengan style transparan/outline
        return ElevatedButton.icon(
          icon: const Icon(Icons.visibility_rounded, size: 18),
          label: const Text("View Details"),
          style: btnStyle.copyWith(
            backgroundColor: WidgetStateProperty.all(Colors.white.withValues(alpha: 0.1)),
            foregroundColor: WidgetStateProperty.all(Colors.white),
            side: WidgetStateProperty.all(const BorderSide(color: Colors.white24)),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EventDetailPage(event: event),
              ),
            );
          },
        );

      case 'cancelled':
        return ElevatedButton.icon(
          icon: const Icon(Icons.block_rounded, size: 18),
          label: const Text("Cancelled"),
          style: btnStyle.copyWith(
            backgroundColor: WidgetStateProperty.all(Colors.white.withValues(alpha: 0.05)),
            foregroundColor: WidgetStateProperty.all(Colors.white38),
          ),
          onPressed: null, // Disabled
        );

      default:
        return const SizedBox.shrink();
    }
  }
}