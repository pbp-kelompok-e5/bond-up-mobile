import 'package:bond_up_mobile/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart' show CookieRequest;
import '../models/participant.dart';
import '../services/event_service.dart';

class ParticipantsPage extends StatefulWidget {
  final int eventId;

  const ParticipantsPage({super.key, required this.eventId});

  @override
  State<ParticipantsPage> createState() => _ParticipantsPageState();
}

class _ParticipantsPageState extends State<ParticipantsPage> {
  late EventService service;
  late Future<List<Participant>> _participantsFuture;

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
      body: FutureBuilder<List<Participant>>(
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
          _buildStatusChip(status),
          const SizedBox(height: 4),
          Text(
            'Joined: ${DateFormat.yMMMd().add_jm().format(participant.joinedAt)}',
            style: theme.textTheme.bodySmall?.copyWith(color: AppColors.gray400),
          ),
        ],
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) => _handleAction(value, participant),
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: "remove",
            child: ListTile(
              leading: Icon(Icons.person_remove, color: AppColors.buttonDanger),
              title: Text("Remove"),
            ),
          ),
          if (status == 'approved')
            const PopupMenuItem(
              value: "mark_attended",
              child: ListTile(
                leading: Icon(Icons.check_circle, color: AppColors.statusCompleted),
                title: Text("Mark Attended"),
              ),
            ),
        ],
      ),
    );
  }

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
        chipColor = AppColors.toastWarningEnd.withOpacity(0.2);
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

    final res = await service.manageParticipant(widget.eventId, action, participant.userId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res["message"] ?? "Action successful!")),
      );
      _reload();
    }
  }

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
