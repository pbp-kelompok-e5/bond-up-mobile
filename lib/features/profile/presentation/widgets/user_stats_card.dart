import 'package:flutter/material.dart';
import 'package:bond_up_mobile/core/design_system.dart';

/// Reusable widget to display user statistics
class UserStatsCard extends StatelessWidget {
  final int totalPoints;
  final int totalEvents;

  const UserStatsCard({
    super.key,
    required this.totalPoints,
    required this.totalEvents,
  });

  @override
  Widget build(BuildContext context) {
    return DeepSeaCard(
      body: Row(
        children: [
          Expanded(
            child: _StatItem(
              icon: '🏆',
              label: 'Points',
              value: totalPoints.toString(),
            ),
          ),
          Container(
            width: 1,
            height: 60,
            color: AppColors.deepSeaLight,
          ),
          Expanded(
            child: _StatItem(
              icon: '📅',
              label: 'Events',
              value: totalEvents.toString(),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          icon,
          style: const TextStyle(fontSize: 32),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.orangeSport,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

