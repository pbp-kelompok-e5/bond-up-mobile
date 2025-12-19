import 'package:bond_up_mobile/core/theme/app_colors.dart';
import 'package:bond_up_mobile/features/event-discovery/services/event_discovery_service.dart';
import '../../event-management/models/event.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class EventPublicDetailPage extends StatefulWidget {
  final Event event;

  const EventPublicDetailPage({super.key, required this.event});

  @override
  State<EventPublicDetailPage> createState() => _EventPublicDetailPageState();
}

class _EventPublicDetailPageState extends State<EventPublicDetailPage> {
  late Event event;
  late EventDiscoveryService _service;
  bool _isJoined = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    event = widget.event;
    _isJoined = event.isJoined ?? false;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final request = context.watch<CookieRequest>();
    _service = EventDiscoveryService(request);
  }

  Future<void> _refreshEvent() async {
    try {
      final updatedEvent = await _service.fetchEventById(event.id);
      if (mounted) {
        setState(() {
          event = updatedEvent;
          _isJoined = updatedEvent.isJoined ?? false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error refreshing event: $e")),
        );
      }
    }
  }

  Future<void> _handleJoinLeave() async {
    setState(() => _isLoading = true);

    try {
      final response = _isJoined
          ? await _service.leaveEvent(event.id)
          : await _service.joinEvent(event.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Success!')),
        );
        await _refreshEvent();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("An error occurred: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool canJoin =
        event.status.toLowerCase() == 'upcoming' || event.status.toLowerCase() == 'open';

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
                        style: theme.textTheme.bodyLarge
                            ?.copyWith(color: AppColors.gray700, height: 1.5),
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
                        value:
                            '${event.currentParticipants}/${event.maxParticipants}',
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
      bottomNavigationBar: canJoin
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                icon: _isLoading
                    ? const SizedBox.shrink()
                    : Icon(_isJoined ? Icons.logout : Icons.login),
                label: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(_isJoined ? "Leave Event" : "Join Event"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isJoined ? AppColors.buttonDanger : AppColors.orangeSport,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: theme.textTheme.labelLarge,
                  disabledBackgroundColor: Colors.grey,
                ),
                onPressed: _isLoading ? null : _handleJoinLeave,
              ),
            )
          : null,
    );
  }

  Widget _buildDetailRow(ThemeData theme,
      {required IconData icon,
      required String label,
      required String value,
      bool isStatus = false}) {
    Color statusColor;
    switch (value.toLowerCase()) {
      case 'upcoming':
      case 'open':
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
