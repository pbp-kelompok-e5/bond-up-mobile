import 'package:flutter/material.dart';
import 'package:bond_up_mobile/core/design_system.dart';
import 'package:bond_up_mobile/core/constants/app_constants.dart';
import 'package:bond_up_mobile/features/profile/data/models/sport_preference_model.dart';

/// Dialog for adding a new sport preference
class AddSportPreferenceDialog extends StatefulWidget {
  final List<SportPreferenceModel> existingPreferences;

  const AddSportPreferenceDialog({
    super.key,
    required this.existingPreferences,
  });

  @override
  State<AddSportPreferenceDialog> createState() =>
      _AddSportPreferenceDialogState();
}

class _AddSportPreferenceDialogState extends State<AddSportPreferenceDialog> {
  String? _selectedSport;
  String? _selectedSkill;

  /// Get list of available sports (excluding already added ones)
  List<MapEntry<String, String>> get _availableSports {
    final existingSportTypes = widget.existingPreferences
        .map((pref) => pref.sportType)
        .toSet();

    return AppConstants.sortedSports
        .where((entry) => !existingSportTypes.contains(entry.key))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final availableSports = _availableSports;

    return AlertDialog(
      backgroundColor: AppColors.deepSeaLight,
      title: const Text(
        'Add Sport Preference',
        style: TextStyle(color: Colors.white),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Show message if no sports available
          if (availableSports.isEmpty) ...[
            const Text(
              'You have already added all available sports!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ] else ...[
            const Text(
              'Sport',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedSport,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.deepSea,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              dropdownColor: AppColors.deepSea,
              style: const TextStyle(color: Colors.white),
              hint: const Text(
                'Select a sport',
                style: TextStyle(color: Colors.white54),
              ),
              items: availableSports.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSport = value;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Skill Level',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedSkill,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.deepSea,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              dropdownColor: AppColors.deepSea,
              style: const TextStyle(color: Colors.white),
              hint: const Text(
                'Select skill level',
                style: TextStyle(color: Colors.white54),
              ),
              items: AppConstants.sortedSkills.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSkill = value;
                });
              },
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            availableSports.isEmpty ? 'Close' : 'Cancel',
            style: const TextStyle(color: Colors.white54),
          ),
        ),
        if (availableSports.isNotEmpty)
          ElevatedButton(
            onPressed: _selectedSport != null && _selectedSkill != null
                ? () {
                    Navigator.pop(context, {
                      'sport_type': _selectedSport,
                      'skill_level': _selectedSkill,
                    });
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.orangeSport,
              foregroundColor: Colors.white,
            ),
            child: const Text('Add'),
          ),
      ],
    );
  }
}

