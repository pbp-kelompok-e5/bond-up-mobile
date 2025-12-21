import 'package:bond_up_mobile/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../services/event_history_service.dart';
import '../models/event_with_status.dart';
import '../models/event.dart';
import 'event_detail_page.dart';
import '../../reviews/presentation/screens/event_reviews_screen.dart';

/// Layar yang menampilkan riwayat acara yang diikuti oleh pengguna saat ini.
/// 
/// Menampilkan daftar acara di mana pengguna terdaftar sebagai peserta,
/// dengan tombol aksi yang berbeda berdasarkan status partisipasi.
class EventHistoryPage extends StatefulWidget {
  /// Membuat [EventHistoryPage].
  const EventHistoryPage({super.key});
  
  @override
  State<EventHistoryPage> createState() => _EventHistoryPageState();
}

class _EventHistoryPageState extends State<EventHistoryPage> {
  /// Layanan untuk mengambil riwayat acara.
  late EventHistoryService service;
  
  /// List acara dengan status partisipasi.
  List<EventWithStatus> eventsWithStatus = [];
  
  /// Flag untuk menandakan proses loading.
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Inisialisasi akan dilakukan di didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Menginisialisasi EventHistoryService menggunakan CookieRequest dari context.
    final request = context.watch<CookieRequest>();
    service = EventHistoryService(request);
    
    // Hanya fetch sekali saat pertama kali
    if (isLoading && eventsWithStatus.isEmpty) {
      _fetchEventHistory();
    }
  }

  /// Mengambil riwayat acara dari API.
  Future<void> _fetchEventHistory() async {
    setState(() => isLoading = true);
    
    final events = await service.fetchEventHistory();
    
    if (mounted) {
      setState(() {
        eventsWithStatus = events;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event History'),
        actions: [
          // Tombol penyegar (refresh) di app bar.
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Refresh",
            onPressed: _fetchEventHistory,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : eventsWithStatus.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _fetchEventHistory,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: eventsWithStatus.length,
                    itemBuilder: (context, index) {
                      final eventWithStatus = eventsWithStatus[index];
                      return _buildEventCard(eventWithStatus, theme);
                    },
                  ),
                ),
    );
  }

  /// Membangun widget untuk keadaan kosong (tidak ada acara).
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 80,
            color: AppColors.gray400,
          ),
          const SizedBox(height: 16),
          Text(
            "No Event History",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.gray600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "You haven't joined any events yet",
            style: TextStyle(
              fontSize: 14,
              color: AppColors.gray500,
            ),
          ),
        ],
      ),
    );
  }

  /// Membangun kartu untuk menampilkan informasi acara.
  Widget _buildEventCard(EventWithStatus eventWithStatus, ThemeData theme) {
    final event = eventWithStatus.event;
    final status = eventWithStatus.participantStatus;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          // Event thumbnail
          if (event.thumbnail.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                event.thumbnail,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 150,
                  color: AppColors.gray300,
                  child: const Icon(Icons.broken_image, size: 50),
                ),
              ),
            ),

          // Event details
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and status chip
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        event.title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildStatusChip(status),
                  ],
                ),
                const SizedBox(height: 12),

                // Date
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: AppColors.gray600),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('d MMMM yyyy').format(event.eventDate),
                      style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.gray700),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Location
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: AppColors.gray600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${event.locationName}, ${event.city}',
                        style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.gray700),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Action button
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

  /// Membangun chip status partisipasi.
  Widget _buildStatusChip(String status) {
    Color chipColor;
    String label;

    switch (status.toLowerCase()) {
      case 'attended':
        chipColor = AppColors.statusCompletedBackground;
        label = 'ATTENDED';
        break;
      case 'joined':
        chipColor = AppColors.statusActiveBackground;
        label = 'JOINED';
        break;
      case 'cancelled':
        chipColor = AppColors.gray300;
        label = 'CANCELLED';
        break;
      default:
        chipColor = AppColors.gray200;
        label = status.toUpperCase();
    }

    return Chip(
      label: Text(label),
      labelStyle: const TextStyle(
        color: AppColors.deepSea,
        fontWeight: FontWeight.bold,
        fontSize: 10,
      ),
      backgroundColor: chipColor,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      visualDensity: VisualDensity.compact,
    );
  }

  /// Membangun tombol aksi berdasarkan status partisipasi.
  Widget _buildActionButton(Event event, String status) {
    switch (status.toLowerCase()) {
      case 'attended':
        // Navigate to event reviews screen
        return ElevatedButton.icon(
          icon: const Icon(Icons.rate_review),
          label: const Text("Write Reviews"),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.orangeSport,
            foregroundColor: AppColors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
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
        // Navigate to event detail page
        return ElevatedButton.icon(
          icon: const Icon(Icons.info_outline),
          label: const Text("View Details"),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.deepSea,
            foregroundColor: AppColors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
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
        // Disabled button
        return ElevatedButton.icon(
          icon: const Icon(Icons.cancel),
          label: const Text("Cancelled"),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.gray400,
            foregroundColor: AppColors.gray600,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          onPressed: null, // Disabled
        );

      default:
        // Default view details button
        return ElevatedButton.icon(
          icon: const Icon(Icons.info_outline),
          label: const Text("View Details"),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.deepSea,
            foregroundColor: AppColors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
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
    }
  }
}

