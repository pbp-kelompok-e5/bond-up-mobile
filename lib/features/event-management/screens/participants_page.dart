import 'package:bond_up_mobile/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart' show CookieRequest;
import '../services/event_service.dart';

class ParticipantsPage extends StatefulWidget {
  final int eventId;

  const ParticipantsPage({super.key, required this.eventId});

  @override
  State<ParticipantsPage> createState() => _ParticipantsPageState();
}

class _ParticipantsPageState extends State<ParticipantsPage> {
  late EventService service;
  late Future<List<Map<String, dynamic>>> _participantsFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final req = context.watch<CookieRequest>();
    service = EventService(req);
    _participantsFuture = service.fetchParticipants(widget.eventId);
  }

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
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _participantsFuture,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
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
                return _buildParticipantTile(data[i]);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildParticipantTile(Map<String, dynamic> participant) {
    final theme = Theme.of(context);
    final username = participant["username"] ?? 'Unknown User';
    final status = participant["status"] ?? 'pending';

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.orangeSport,
        foregroundColor: AppColors.white,
        child: Text(username.isNotEmpty ? username[0].toUpperCase() : '?'),
      ),
      title: Text(username, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
      subtitle: _buildStatusChip(status),
      trailing: PopupMenuButton<String>(
        onSelected: (value) => _handleAction(value, participant["user_id"]),
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: "remove",
            child: Text("Remove Participant"),
          ),
          if (status == 'approved')
            const PopupMenuItem(
              value: "mark_attended",
              child: Text("Mark as Attended"),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    Color textColor;
    String label = status.replaceAll('_', ' ').toUpperCase();

    switch (status) {
      case 'approved':
        chipColor = AppColors.statusActiveBackground;
        textColor = AppColors.statusActive;
        break;
      case 'attended':
        chipColor = AppColors.statusCompletedBackground;
        textColor = AppColors.statusCompleted;
        break;
      case 'pending':
        chipColor = AppColors.toastWarningEnd.withOpacity(0.2);
        textColor = AppColors.toastWarningEnd;
        break;
      default:
        chipColor = AppColors.gray200;
        textColor = AppColors.gray700;
    }

    return Chip(
      label: Text(label),
      labelStyle: TextStyle(
        color: textColor,
        fontWeight: FontWeight.bold,
        fontSize: 10,
      ),
      backgroundColor: chipColor,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      visualDensity: VisualDensity.compact,
    );
  }

  void _handleAction(String action, int userId) async {
    final res = await service.manageParticipant(widget.eventId, action, userId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res["message"] ?? "Action successful!")),
      );
      _reload();
    }
  }
}
