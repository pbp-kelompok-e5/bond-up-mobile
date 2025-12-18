import 'package:bond_up_mobile/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../services/event_service.dart';
import '../models/event.dart';
import 'event_form_page.dart';
import 'event_detail_page.dart';

class MyEventsPage extends StatefulWidget {
  const MyEventsPage({super.key});
  @override
  State<MyEventsPage> createState() => _MyEventsPageState();
}

class _MyEventsPageState extends State<MyEventsPage> {
  late EventService service;
  late Future<List<Event>> futureEvents;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final req = context.watch<CookieRequest>();
    service = EventService(req);
    _refresh();
  }

  void _refresh() {
    setState(() {
      futureEvents = service.fetchMyEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Events'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 28),
            tooltip: "Create Event",
            onPressed: () async {
              final created = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EventFormPage()),
              );
              if (created == true) {
                _refresh();
              }
            },
          ),
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
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));

          final allEvents = snap.data ?? [];
          if (allEvents.isEmpty) {
            return const Center(
              child: Text(
                'You have not created any events yet.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

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
                _buildSection("Upcoming Events", upcoming),
                const SizedBox(height: 24),
                _buildSection("Past Events", past, isPast: true),
              ],
            ),
          );
        },
      ),
    );
  }

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
        ...events.map((e) => _buildEventCard(e, isPast)),
      ],
    );
  }

  Widget _buildEventCard(Event event, bool isPast) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () async {
          final updated = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => EventDetailPage(event: event)),
          );
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
                  _buildStatusChip(event.status),
                  Text(
                    '${event.currentParticipants}/${event.maxParticipants} joined',
                    style: theme.textTheme.bodySmall?.copyWith(color: AppColors.gray300),
                  ),
                ],
              ),
              if (!isPast) ...[
                const Divider(height: 24, color: AppColors.deepSeaLighter),
                _buildActionButtons(event),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    String chipText = status.toUpperCase();

    switch (status.toLowerCase()) {
      case 'upcoming':
      case 'open':
        chipColor = AppColors.statusActiveBackground;
        chipText = 'UPCOMING';
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
      labelStyle: const TextStyle(
        color: AppColors.white,
        fontWeight: FontWeight.bold,
        fontSize: 10,
      ),
      backgroundColor: chipColor,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildActionButtons(Event event) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (event.status.toLowerCase() == "open") ...[
          TextButton.icon(
            icon: const Icon(Icons.people, size: 16),
            label: const Text("Participants"),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.statusCompleted,
            ),
            onPressed: () {
              // TODO: Implement navigation to a participants management page.
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Participants page not yet implemented."),
              ));
            },
          ),
          TextButton.icon(
            icon: const Icon(Icons.edit, size: 16),
            label: const Text("Edit"),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.gray200,
            ),
            onPressed: () => _editEvent(event),
          ),
          TextButton.icon(
            icon: const Icon(Icons.cancel, size: 16),
            label: const Text("Cancel"),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.statusCancelled,
            ),
            onPressed: () => _cancelEvent(event),
          ),
        ],
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

  void _editEvent(Event event) async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EventFormPage(event: event)),
    );
    if (updated == true) _refresh();
  }

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
