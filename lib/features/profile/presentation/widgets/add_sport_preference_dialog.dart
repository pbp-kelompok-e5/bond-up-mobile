import 'package:flutter/material.dart';
import 'package:bond_up_mobile/core/design_system.dart';
import 'package:bond_up_mobile/core/theme/app_colors.dart';
import 'package:bond_up_mobile/core/constants/app_constants.dart';
import 'package:bond_up_mobile/features/profile/data/models/sport_preference_model.dart';

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

  List<MapEntry<String, String>> get _availableSports {
    final existingSportTypes =
        widget.existingPreferences.map((pref) => pref.sportType).toSet();

    return AppConstants.sortedSports
        .where((entry) => !existingSportTypes.contains(entry.key))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final availableSports = _availableSports;

    return AlertDialog(
      backgroundColor: AppColors.deepSeaLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.library_add_rounded, color: AppColors.orangeSport),
          SizedBox(width: 12),
          Text(
            'Add Sport',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (availableSports.isEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                children: [
                  Icon(Icons.emoji_events_rounded,
                      size: 48, color: Colors.white24),
                  SizedBox(height: 12),
                  Text(
                    'You have mastered everything!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'No more sports available to add.',
                    style: TextStyle(fontSize: 14, color: Colors.white54),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ] else ...[
            // --- DROPDOWN SPORT ---
            const Text(
              'Sport Type',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.orangeSport,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedSport,
              dropdownColor:
                  AppColors.deepSea, // Warna background menu saat dibuka

              // 1. Style untuk Teks Item yang SEDANG DIPILIH
              style: const TextStyle(color: Colors.white, fontSize: 16),

              // 2. Style untuk HINT (Placeholder) - INI YANG MEMBUATNYA PUTIH
              hint: const Text(
                'Select a sport',
                style: TextStyle(color: Colors.white70),
              ),

              icon: const Icon(Icons.keyboard_arrow_down_rounded,
                  color: AppColors.orangeSport),

              decoration: InputDecoration(
                filled: false,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                prefixIcon: const Icon(Icons.directions_run_rounded,
                    color: AppColors.orangeSport),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                      color: AppColors.orangeSport, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                      color: AppColors.orangeSportHover, width: 2.0),
                ),
              ),

              items: availableSports.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key,
                  // 3. Style untuk Teks DI DALAM MENU list
                  child: Text(
                    entry.value,
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),

              onChanged: (value) => setState(() => _selectedSport = value),
            ),

            const SizedBox(height: 20),

            // --- DROPDOWN SKILL ---
            const Text(
              'Skill Level',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.orangeSport,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedSkill,
              dropdownColor: AppColors.deepSea,

              // 1. Style Item Terpilih
              style: const TextStyle(color: Colors.white, fontSize: 16),

              // 2. Style Hint
              hint: const Text(
                'Select skill level',
                style: TextStyle(color: Colors.white70),
              ),

              icon: const Icon(Icons.keyboard_arrow_down_rounded,
                  color: AppColors.orangeSport),

              decoration: InputDecoration(
                filled: false,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                prefixIcon: const Icon(Icons.star_outline_rounded,
                    color: AppColors.orangeSport),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                      color: AppColors.orangeSport, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                      color: AppColors.orangeSportHover, width: 2.0),
                ),
              ),

              items: AppConstants.sortedSkills.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key,
                  // 3. Style Item Menu
                  child: Text(
                    entry.value,
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),

              onChanged: (value) => setState(() => _selectedSkill = value),
            ),
          ],
        ],
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            foregroundColor: Colors.white54,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          child: Text(availableSports.isEmpty ? 'Close' : 'Cancel'),
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
              disabledBackgroundColor: AppColors.orangeSport.withValues(alpha: 0.3),
              disabledForegroundColor: Colors.white38,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Add Sport',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
      ],
    );
  }
}
