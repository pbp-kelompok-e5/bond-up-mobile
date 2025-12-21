import 'package:bond_up_mobile/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../services/event_service.dart';
import '../models/event.dart';
import 'event_form_page.dart';
import 'event_detail_page.dart';
import 'participants_page.dart';

/// Layar yang menampilkan daftar acara yang dibuat oleh pengguna saat ini.
class MyEventsPage extends StatefulWidget {
  /// Membuat [MyEventsPage].
  const MyEventsPage({super.key});
  @override
  State<MyEventsPage> createState() => _MyEventsPageState();
}

class _MyEventsPageState extends State<MyEventsPage> {
  /// Layanan (service) untuk pemanggilan API terkait acara.
  late EventService service;

  /// Future yang akan menampung daftar acara yang diambil dari API.
  late Future<List<Event>> futureEvents;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Inisialisasi EventService menggunakan CookieRequest dari context.
    final req = context.watch<CookieRequest>();
    service = EventService(req);
    // Segarkan daftar acara saat dependensi berubah (misal: setelah login/logout).
    _refresh();
  }

  /// Menyegarkan daftar acara dengan mengambil ulang data dari API.
  void _refresh() {
    setState(() {
      futureEvents = service.fetchMyEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Event'),
        actions: [
          // Tombol penyegar (refresh) di app bar.
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Refresh",
            onPressed: _refresh,
          ),
        ],
      ),
      body: FutureBuilder<List<Event>>(
        future: futureEvents,
        builder: (context, snap) {
          // Menampilkan indikator pemuatan saat mengambil data.
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          // Menampilkan pesan kesalahan jika pengambilan data gagal.
          if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));

          final allEvents = snap.data ?? [];
          // Menampilkan pesan jika tidak ada acara yang ditemukan.
          if (allEvents.isEmpty) {
            return const Center(
              child: Text(
                'You have not created any events yet.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          // Memisahkan acara menjadi acara mendatang dan acara lampau.
          final today = DateTime.now();
          final upcoming = allEvents
              .where((e) => !e.eventDate.isBefore(today))
              .toList();
          final past = allEvents.where((e) => e.eventDate.isBefore(today)).toList();

          return RefreshIndicator(
            onRefresh: () async => _refresh(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Membangun bagian untuk acara mendatang dan acara lampau.
                _buildSection("Upcoming Events", upcoming),
                const SizedBox(height: 24),
                _buildSection("Past Events", past, isPast: true),
              ],
            ),
          );
        },
      ),
      // Tombol aksi mengambang untuk menambah acara baru.
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Navigasi ke EventFormPage untuk pembuatan acara baru.
          final created = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EventFormPage()),
          );
          // Segarkan daftar jika acara baru berhasil dibuat.
          if (created == true) {
            _refresh();
          }
        },
        label: const Text("Add Event"),
        icon: const Icon(Icons.add),
        backgroundColor: AppColors.orangeSport,
        foregroundColor: AppColors.white,
      ),
    );
  }

  /// Membangun bagian (section) untuk daftar acara (misal: "Upcoming Events").
  Widget _buildSection(String title, List<Event> events, {bool isPast = false}) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: AppColors.orangeSport,
          ),
        ),
        const SizedBox(height: 12),
        // Menampilkan pesan jika tidak ada acara dalam kategori ini.
        if (events.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32.0),
            child: Center(
              child: Text(
                "No events in this category.",
                style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.gray500),
              ),
            ),
          ),
        // Membangun kartu acara untuk setiap item.
        ...events.map((e) => _buildEventCard(e, isPast)),
      ],
    );
  }

  /// Membangun widget kartu untuk menampilkan ringkasan informasi acara.
  Widget _buildEventCard(Event event, bool isPast) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () async {
          // Navigasi ke EventDetailPage saat kartu ditekan.
          final updated = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => EventDetailPage(event: event)),
          );
          // Segarkan daftar jika ada perubahan pada halaman detail.
          if (updated == true) {
            _refresh();
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.title,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today, color: AppColors.gray400, size: 14),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('d MMMM yyyy').format(event.eventDate),
                    style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.gray300),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on, color: AppColors.gray400, size: 14),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${event.locationName}, ${event.city}',
                      style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.gray300),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Menampilkan status acara dalam bentuk chip berwarna.
                  _buildStatusChip(event.status),
                  Text(
                    '${event.currentParticipants}/${event.maxParticipants} joined',
                    style: theme.textTheme.bodySmall?.copyWith(color: AppColors.gray300),
                  ),
                ],
              ),
              const Divider(height: 24, color: AppColors.deepSeaLighter),
              // Membangun tombol aksi untuk setiap kartu acara.
              _buildActionButtons(event, isPast: isPast),
            ],
          ),
        ),
      ),
    );
  }

  /// Membangun widget chip berwarna untuk menampilkan status acara.
  Widget _buildStatusChip(String status) {
    Color chipColor;
    Color textColor = AppColors.deepSea;
    String chipText = status.toUpperCase();

    switch (status.toLowerCase()) {
      case 'upcoming':
      case 'open':
        chipColor = AppColors.statusActiveBackground;
        chipText = status.toUpperCase();
        break;
      case 'cancelled':
        chipColor = AppColors.statusCancelledBackground;
        break;
      case 'completed':
        chipColor = AppColors.statusCompletedBackground;
        break;
      default:
        chipColor = Colors.grey;
    }

    return Chip(
      label: Text(chipText),
      labelStyle: TextStyle(
        color: textColor,
        fontWeight: FontWeight.bold,
        fontSize: 10,
      ),
      backgroundColor: chipColor,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      visualDensity: VisualDensity.compact,
    );
  }

  /// Membangun tombol aksi (Participants, Edit, Cancel, Delete) untuk kartu acara.
  ///
  /// Tombol bersifat kondisional berdasarkan status dan apakah acara sudah lampau.
  Widget _buildActionButtons(Event event, {bool isPast = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (!isPast && event.status.toLowerCase() == "open") ...[
          // Tombol untuk melihat/mengelola peserta.
          TextButton.icon(
            icon: const Icon(Icons.people, size: 16),
            label: const Text("Participants"),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.statusCompleted,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ParticipantsPage(eventId: event.id)),
              );
            },
          ),
          // Tombol untuk menyunting acara.
          TextButton.icon(
            icon: const Icon(Icons.edit, size: 16),
            label: const Text("Edit"),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.gray200,
            ),
            onPressed: () => _editEvent(event),
          ),
          // Tombol untuk membatalkan acara.
          TextButton.icon(
            icon: const Icon(Icons.cancel, size: 16),
            label: const Text("Cancel"),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.statusCancelled,
            ),
            onPressed: () => _cancelEvent(event),
          ),
        ],
        // Tombol untuk menghapus acara secara permanen.
        TextButton.icon(
          icon: const Icon(Icons.delete_forever, size: 16),
          label: const Text("Delete"),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.buttonDanger,
          ),
          onPressed: () => _deleteEvent(event),
        ),
      ],
    );
  }

  /// Menangani navigasi ke [EventFormPage] untuk menyunting acara.
  ///
  /// Segarkan daftar jika data berhasil diperbarui.
  void _editEvent(Event event) async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EventFormPage(event: event)),
    );
    if (updated == true) _refresh();
  }

  /// Menangani proses penghapusan acara.
  ///
  /// Menampilkan dialog konfirmasi sebelum melanjutkan penghapusan.
  void _deleteEvent(Event event) async {
    final confirm = await _showConfirmationDialog(
      title: "Confirm Deletion",
      content: "Are you sure you want to permanently delete this event? This action cannot be undone.",
      confirmText: "Delete",
    );

    if (confirm) {
      final res = await service.deleteEvent(event.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res["message"])));
      _refresh();
    }
  }

  /// Menangani proses pembatalan acara.
  ///
  /// Menampilkan dialog konfirmasi sebelum melanjutkan pembatalan.
  void _cancelEvent(Event event) async {
    final confirm = await _showConfirmationDialog(
      title: "Confirm Cancellation",
      content: "Are you sure you want to cancel this event?",
      confirmText: "Yes, Cancel",
    );

    if (confirm) {
      final res = await service.cancelEvent(event.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res["message"])));
      _refresh();
    }
  }

  /// Menampilkan dialog konfirmasi umum.
  ///
  /// Mengembalikan `true` jika dikonfirmasi, dan `false` jika tidak.
  Future<bool> _showConfirmationDialog({
    required String title,
    required String content,
    String confirmText = "Confirm",
  }) async {
    return await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.deepSeaLight,
        title: Text(title, style: const TextStyle(color: AppColors.white)),
        content: Text(content, style: const TextStyle(color: AppColors.gray300)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("No", style: TextStyle(color: AppColors.gray300)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              backgroundColor: AppColors.buttonDanger,
              foregroundColor: AppColors.white,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    ) ?? false;
  }
}