import 'package:bond_up_mobile/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../models/event.dart';
import 'participants_page.dart';
import 'event_form_page.dart';
import '../services/event_service.dart';

class EventDetailPage extends StatefulWidget {
  final Event event;

  const EventDetailPage({super.key, required this.event});

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  late Event event;
  late EventService service;

  @override
  void initState() {
    super.initState();
    event = widget.event;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final request = context.watch<CookieRequest>();
    service = EventService(request);
  }

  void _refreshEvent() async {
    final updatedEvent = await service.fetchEventDetail(event.id);
    setState(() {
      event = updatedEvent;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            pinned: true,
            floating: false,
            backgroundColor: AppColors.deepSea,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: _buildAppBarActions(),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                event.title,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Hero(
                tag: 'event-thumbnail-${event.id}',
                child: Image.network(
                  event.thumbnail,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey,
                    child: const Icon(Icons.broken_image, size: 50, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.description,
                        style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.gray700, height: 1.5),
                      ),
                      const SizedBox(height: 24),
                      const Divider(),
                      _buildDetailRow(
                        theme,
                        icon: Icons.sports_soccer,
                        label: "Sport",
                        value: event.sportType,
                      ),
                      _buildDetailRow(
                        theme,
                        icon: Icons.location_city,
                        label: "City",
                        value: event.city,
                      ),
                      _buildDetailRow(
                        theme,
                        icon: Icons.place,
                        label: "Location",
                        value: event.locationName,
                      ),
                      _buildDetailRow(
                        theme,
                        icon: Icons.calendar_today,
                        label: "Date",
                        value: DateFormat('d MMMM yyyy').format(event.eventDate),
                      ),
                      _buildDetailRow(
                        theme,
                        icon: Icons.access_time,
                        label: "Time",
                        value: '${event.startTime} - ${event.endTime}',
                      ),
                      _buildDetailRow(
                        theme,
                        icon: Icons.group,
                        label: "Participants",
                        value: '${event.currentParticipants}/${event.maxParticipants}',
                      ),
                      _buildDetailRow(
                        theme,
                        icon: Icons.info_outline,
                        label: "Status",
                        value: event.status.toUpperCase(),
                        isStatus: true,
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          icon: const Icon(Icons.people_alt_outlined),
          label: const Text("Manage Participants"),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.orangeSport,
            foregroundColor: AppColors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: theme.textTheme.labelLarge,
          ),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ParticipantsPage(eventId: event.id),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildAppBarActions() {
    return [
      if (event.status == "upcoming")
        IconButton(
          icon: const Icon(Icons.edit),
          tooltip: "Edit Event",
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => EventFormPage(event: event)),
            );
            if (result == true && mounted) {
              _refreshEvent();
              Navigator.pop(context, true); // Pop back to MyEventsPage with update flag
            }
          },
        ),
      if (event.status == "upcoming")
        IconButton(
          icon: const Icon(Icons.cancel),
          tooltip: "Cancel Event",
          onPressed: () async {
            final confirm = await _showConfirmationDialog(
              title: "Confirm Cancellation",
              content: "Are you sure you want to cancel this event?",
              confirmText: "Yes, Cancel",
            );

            if (confirm) {
              final res = await service.cancelEvent(event.id);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res["message"])));
              Navigator.pop(context, true); // Pop back to MyEventsPage with update flag
            }
          },
        ),
      IconButton(
        icon: const Icon(Icons.delete),
        tooltip: "Delete Event",
        onPressed: () async {
          final confirm = await _showConfirmationDialog(
            title: "Confirm Deletion",
            content: "Are you sure you want to permanently delete this event?",
            confirmText: "Delete",
          );

          if (confirm) {
            final res = await service.deleteEvent(event.id);
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res["message"])));
            Navigator.pop(context, true); // Pop back to MyEventsPage with update flag
          }
        },
      ),
    ];
  }

  Widget _buildDetailRow(ThemeData theme,
      {required IconData icon, required String label, required String value, bool isStatus = false}) {
    Color statusColor;
    switch (value.toLowerCase()) {
      case 'upcoming':
        statusColor = AppColors.statusActive;
        break;
      case 'cancelled':
        statusColor = AppColors.statusCancelled;
        break;
      case 'completed':
        statusColor = AppColors.statusCompleted;
        break;
      default:
        statusColor = AppColors.gray700;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.orangeSport, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Text.rich(
              TextSpan(
                text: '$label: ',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.gray800,
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(
                    text: value,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: isStatus ? statusColor : AppColors.gray700,
                      fontWeight: isStatus ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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
    ) ??
        false;
  }
}
