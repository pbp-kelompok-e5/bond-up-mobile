import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bond_up_mobile/core/design_system.dart'; 
import 'package:bond_up_mobile/core/constants/app_constants.dart';
import '../../logic/browse_users_provider.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  String? tempSport;
  String? tempSkill;
  String? tempCity;

  @override
  void initState() {
    super.initState();
    final provider = context.read<BrowseUsersProvider>();
    tempSport = provider.selectedSport;
    tempSkill = provider.selectedSkill;
    tempCity = provider.selectedCity;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<BrowseUsersProvider>();
    return Container(
      padding: const EdgeInsets.all(16),
      height: MediaQuery.of(context).size.height * 0.7,
      // Background Modal Gelap
      decoration: const BoxDecoration(
        color: AppColors.deepSea, 
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Filter Options", 
                style: TextStyle(
                  fontSize: 20, 
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Text Putih
                ),
              ),
              TextButton(
                onPressed: () {
                  provider.clearFilters();
                  Navigator.pop(context);
                },
                child: const Text(
                  "Reset",
                  style: TextStyle(color: AppColors.orangeSport), // Text Orange
                ),
              )
            ],
          ),
          const Divider(color: AppColors.deepSeaLighter), // Garis pembatas samar
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildDropdown(
                    label: "Sport",
                    value: tempSport,
                    items: AppConstants.sortedSports,
                    onChanged: (val) => setState(() => tempSport = val),
                  ),
                  const SizedBox(height: 16),

                  _buildDropdown(
                    label: "Skill Level",
                    value: tempSkill,
                    items: AppConstants.sortedSkills,
                    onChanged: (val) => setState(() => tempSkill = val),
                  ),
                  const SizedBox(height: 16),

                  _buildDropdown(
                    label: "City",
                    value: tempCity,
                    items: AppConstants.sortedCities,
                    onChanged: (val) => setState(() => tempCity = val),
                  ),
                ],
              ),
            ),
          ),

          // Tombol Apply 
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: AppButton(
              text: "Apply Filters",
              variant: ButtonVariant.primary,
              isFullWidth: true,
              onPressed: () {
                provider.applyFilters(
                  sport: tempSport,
                  skill: tempSkill,
                  city: tempCity,
                );
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<MapEntry<String, String>> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label, 
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white, // Label Putih
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: (value != null && value.isNotEmpty) ? value : null,
          dropdownColor: AppColors.deepSeaLight, // Background Menu saat dibuka
          style: const TextStyle(color: Colors.white), // Text item putih
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.deepSeaLight, // Warna kolom input
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.orangeSport), // Border Orange pas aktif
            ),
          ),
          hint: Text(
            "Select $label",
            style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
          ),
          icon: const Icon(Icons.arrow_drop_down, color: AppColors.orangeSport), // Panah Orange
          items: [
            const DropdownMenuItem(
              value: '', 
              child: Text("All", style: TextStyle(color: Colors.white70))
            ),
            ...items.map((entry) {
              return DropdownMenuItem<String>(
                value: entry.key,
                child: Text(entry.value),
              );
            }),
          ],
          onChanged: onChanged,
        ),
      ],
    );
  }
}