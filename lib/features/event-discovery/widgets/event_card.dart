import 'package:bond_up_mobile/core/theme/app_colors.dart';
import '../../event-management/models/event.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;

  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildThumbnail(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusChip(event.status),
                  const SizedBox(height: 8),
                  Text(
                    event.title,
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold, color: AppColors.white),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    theme,
                    icon: Icons.calendar_today,
                    text: DateFormat('d MMMM yyyy').format(event.eventDate),
                  ),
                  const SizedBox(height: 6),
                  _buildInfoRow(
                    theme,
                    icon: Icons.location_on_outlined,
                    text: '${event.locationName}, ${event.city}',
                  ),
                  const SizedBox(height: 6),
                  _buildInfoRow(
                    theme,
                    icon: Icons.sports_soccer_outlined,
                    text: event.sportType,
                  ),
                  const Divider(height: 24, color: AppColors.deepSeaLighter),
                  _buildFooter(theme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    return Hero(
      tag: 'event-thumbnail-${event.id}',
      child: Image.network(
        event.thumbnail,
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          height: 180,
          color: AppColors.deepSeaLighter,
          child: const Icon(Icons.sports, size: 60, color: AppColors.gray500),
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

  Widget _buildInfoRow(ThemeData theme, {required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, color: AppColors.gray400, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.gray300),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text.rich(
          TextSpan(
            style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.gray100),
            children: [
              TextSpan(
                text: event.currentParticipants.toString(),
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.orangeSport),
              ),
              TextSpan(text: '/${event.maxParticipants} Joined'),
            ],
          ),
        ),
        Text(
          'by ${event.organizerUsername}', // Assuming organizer username is available
          style: theme.textTheme.bodySmall?.copyWith(color: AppColors.gray400),
        )
      ],
    );
  }
}
