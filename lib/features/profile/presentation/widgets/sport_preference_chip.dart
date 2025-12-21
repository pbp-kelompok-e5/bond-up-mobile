import 'package:flutter/material.dart';
import 'package:bond_up_mobile/core/design_system.dart';
import 'package:bond_up_mobile/features/profile/data/models/sport_preference_model.dart';

/// Reusable widget to display a sport preference chip
class SportPreferenceChip extends StatelessWidget {
  final SportPreferenceModel preference;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const SportPreferenceChip({
    super.key,
    required this.preference,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AppChip(
      label: '${preference.sportEmoji} ${preference.sportTypeDisplay} - ${preference.skillEmoji} ${preference.skillLevelDisplay}',
      onTap: onTap,
      onDelete: onDelete,
    );
  }
}

/// Widget to display a grid of sport preference chips
class SportPreferencesGrid extends StatelessWidget {
  final List<SportPreferenceModel> preferences;
  final Function(SportPreferenceModel)? onTap;
  final Function(SportPreferenceModel)? onDelete;

  const SportPreferencesGrid({
    super.key,
    required this.preferences,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (preferences.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '🏃',
                style: TextStyle(fontSize: 48),
              ),
              SizedBox(height: 16),
              Text(
                'No sport preferences yet',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Add your favorite sports to get started!',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: preferences.map((preference) {
        return SportPreferenceChip(
          preference: preference,
          onTap: onTap != null ? () => onTap!(preference) : null,
          onDelete: onDelete != null ? () => onDelete!(preference) : null,
        );
      }).toList(),
    );
  }
}

