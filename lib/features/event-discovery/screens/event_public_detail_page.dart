import 'package:bond_up_mobile/core/theme/app_colors.dart';
import '../../event-management/models/event.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventPublicDetailPage extends StatefulWidget {
  final Event event;

  const EventPublicDetailPage({super.key, required this.event});

  @override
  State<EventPublicDetailPage> createState() => _EventPublicDetailPageState();
}

class _EventPublicDetailPageState extends State<EventPublicDetailPage> {
  late Event event;
  // TODO: Add service and state for join/leave functionality

  @override
  void initState() {
    super.initState();
    event = widget.event;
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
                        icon: Icons.person_outline,
                        label: "Organizer",
                        value: event.organizerUsername,
                      ),
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
          icon: const Icon(Icons.login),
          label: const Text("Join Event"),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.orangeSport,
            foregroundColor: AppColors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: theme.textTheme.labelLarge,
          ),
          onPressed: () {
            // TODO: Implement Join/Leave logic
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Join/Leave functionality not implemented yet.")),
            );
          },
        ),
      ),
    );
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
}
