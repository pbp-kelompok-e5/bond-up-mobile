import 'package:bond_up_mobile/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart' show CookieRequest;
import '../models/participant.dart';
import '../services/event_service.dart';

/// Layar untuk menampilkan dan mengelola daftar peserta untuk acara tertentu.
class ParticipantsPage extends StatefulWidget {
  /// ID acara yang pesertanya akan ditampilkan.
  final int eventId;

  /// Membuat [ParticipantsPage] untuk [eventId] yang diberikan.
  const ParticipantsPage({super.key, required this.eventId});

  @override
  State<ParticipantsPage> createState() => _ParticipantsPageState();
}

class _ParticipantsPageState extends State<ParticipantsPage> {
  /// Layanan (service) untuk pemanggilan API terkait acara.
  late EventService service;

  /// Future yang akan menampung daftar peserta yang diambil dari API.
  late Future<List<Participant>> _participantsFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Inisialisasi EventService menggunakan CookieRequest dari context.
    final req = context.watch<CookieRequest>();
    service = EventService(req);
    // Mengambil data peserta saat dependensi berubah.
    _participantsFuture = service.fetchParticipants(widget.eventId);
  }

  /// Memuat ulang daftar peserta dengan mengambil data kembali dari API.
  void _reload() {
    setState(() {
      _participantsFuture = service.fetchParticipants(widget.eventId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Participants"),
      ),
      body: FutureBuilder<List<Participant>>(
        future: _participantsFuture,
        builder: (context, snap) {
          // Menampilkan indikator pemuatan saat mengambil data peserta.
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          // Menampilkan pesan jika tidak ada peserta atau terjadi kesalahan.
          if (snap.hasError || !snap.hasData || snap.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.people_outline, size: 80, color: AppColors.gray400),
                  const SizedBox(height: 16),
                  Text(
                    "No participants have joined yet.",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            );
          }

          final data = snap.data!;

          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView.separated(
              itemCount: data.length,
              padding: const EdgeInsets.symmetric(vertical: 8),
              separatorBuilder: (context, index) => const Divider(indent: 16, endIndent: 16),
              itemBuilder: (_, i) {
                // Membangun ubin (tile) untuk setiap peserta.
                return _buildParticipantTile(data[i]);
              },
            ),
          );
        },
      ),
    );
  }

  /// Membangun widget [ListTile] untuk menampilkan informasi satu peserta.
  Widget _buildParticipantTile(Participant participant) {
    final theme = Theme.of(context);
    final username = participant.username;
    final status = participant.status;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.orangeSport,
        foregroundColor: AppColors.white,
        child: Text(username.isNotEmpty ? username[0].toUpperCase() : '?'),
      ),
      title: Text(username, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          // Menampilkan status peserta dalam bentuk chip berwarna.
          _buildStatusChip(status),
          const SizedBox(height: 4),
          Text(
            'Joined: ${DateFormat.yMMMd().add_jm().format(participant.joinedAt)}',
            style: theme.textTheme.bodySmall?.copyWith(color: AppColors.gray400),
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (status == 'joined')
            IconButton(
              icon: const Icon(Icons.check_circle),
              color: AppColors.statusCompleted,
              tooltip: "Mark Attended",
              onPressed: () => _handleAction('mark_attended', participant),
            ),
          if (status == 'attended')
            IconButton(
              icon: const Icon(Icons.undo),
              color: AppColors.toastWarningEnd,
              tooltip: "Unmark Attended",
              onPressed: () => _handleAction('unmark_attended', participant),
            ),
          IconButton(
            icon: const Icon(Icons.person_remove),
            color: AppColors.buttonDanger,
            tooltip: "Remove Participant",
            onPressed: () => _handleAction('remove', participant),
          ),
        ],
      ),
    );
  }

  /// Membangun widget chip berwarna untuk menampilkan status peserta.
  Widget _buildStatusChip(String status) {
    Color chipColor;
    String label = status.replaceAll('_', ' ').toUpperCase();

    switch (status) {
      case 'approved':
        chipColor = AppColors.statusActiveBackground;
        break;
      case 'attended':
        chipColor = AppColors.statusCompletedBackground;
        break;
      case 'pending':
        chipColor = AppColors.toastWarningEnd.withValues(alpha: 0.2);
        break;
      default:
        chipColor = AppColors.gray200;
    }

    return Chip(
      label: Text(label),
      labelStyle: const TextStyle(
        color: AppColors.deepSea,
        fontWeight: FontWeight.bold,
        fontSize: 10,
      ),
      backgroundColor: chipColor,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      visualDensity: VisualDensity.compact,
    );
  }

  /// Menangani aksi yang dilakukan pada peserta (hapus, tandai hadir).
  ///
  /// Menampilkan dialog konfirmasi sebelum menjalankan aksi tersebut.
  void _handleAction(String action, Participant participant) async {
    String title;
    String content;
    String confirmText;
    bool isDestructive;

    if (action == 'remove') {
      title = 'Remove Participant?';
      content = 'Are you sure you want to remove ${participant.username}?';
      confirmText = 'Remove';
      isDestructive = true;
    } else if (action == 'mark_attended') {
      title = 'Mark as Attended?';
      content = 'Are you sure you want to mark ${participant.username} as attended?';
      confirmText = 'Mark Attended';
      isDestructive = false;
    } else if (action == 'unmark_attended') {
      title = 'Unmark Attended?';
      content = 'Are you sure you want to unmark ${participant.username} as attended?';
      confirmText = 'Unmark';
      isDestructive = false;
    } else {
      return;
    }

    final confirm = await _showConfirmationDialog(
      title: title,
      content: content,
      confirmText: confirmText,
      isDestructive: isDestructive,
    );

    if (!confirm || !mounted) return;

    // Memanggil layanan untuk mengelola peserta.
    final res = await service.manageParticipant(widget.eventId, action, participant.userId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res["message"] ?? "Action successful!")),
      );
      // Memuat ulang daftar peserta setelah aksi berhasil dilakukan.
      _reload();
    }
  }

  /// Menampilkan dialog konfirmasi umum.
  ///
  /// Menerima [title], [content], serta [confirmText] dan flag [isDestructive] opsional.
  /// Mengembalikan `true` jika pengguna mengonfirmasi, dan `false` jika tidak.
  Future<bool> _showConfirmationDialog({
    required String title,
    required String content,
    String confirmText = "Confirm",
    bool isDestructive = false,
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
                child: const Text("Cancel", style: TextStyle(color: AppColors.gray300)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: TextButton.styleFrom(
                  backgroundColor: isDestructive ? AppColors.buttonDanger : AppColors.statusActive,
                  foregroundColor: AppColors.white,
                ),
                child: Text(confirmText),
              ),
            ],
          ),
        ) ??
        false;
  }
}