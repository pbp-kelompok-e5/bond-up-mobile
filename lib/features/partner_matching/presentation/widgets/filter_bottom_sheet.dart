import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/browse_users_provider.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  // Variable lokal buat nampung pilihan sementara sebelum di-Apply
  String? tempSport;
  String? tempSkill;
  String? tempCity;

  @override
  void initState() {
    super.initState();
    // Load opsi filter dari API pas modal dibuka
    final provider = context.read<BrowseUsersProvider>();
    
    // Isi nilai awal sesuai yang ada di provider
    tempSport = provider.selectedSport;
    tempSkill = provider.selectedSkill;
    tempCity = provider.selectedCity;

    // Fetch opsi kalau belum ada
    Future.microtask(() => provider.loadFiltersOptions());
  }

  @override
  Widget build(BuildContext context) {
    // Pake Consumer biar modalnya ke-update pas opsi filter dari API dateng
    return Consumer<BrowseUsersProvider>(
      builder: (context, provider, child) {
        final options = provider.filters;

        return Container(
          padding: const EdgeInsets.all(16),
          // Biar modalnya gak ketutupan keyboard/full screen
          height: MediaQuery.of(context).size.height * 0.7, 
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Filter Options", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () {
                      provider.clearFilters();
                      Navigator.pop(context);
                    },
                    child: const Text("Reset"),
                  )
                ],
              ),
              const Divider(),
              
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Dropdown Sport
                      _buildDropdown(
                        label: "Sport",
                        value: tempSport,
                        items: options['sports'] ?? [],
                        onChanged: (val) => setState(() => tempSport = val),
                      ),
                      const SizedBox(height: 16),

                      // Dropdown Skill
                      _buildDropdown(
                        label: "Skill Level",
                        value: tempSkill,
                        items: options['skills'] ?? [],
                        onChanged: (val) => setState(() => tempSkill = val),
                      ),
                      const SizedBox(height: 16),

                      // Dropdown City
                      _buildDropdown(
                        label: "City",
                        value: tempCity,
                        items: options['cities'] ?? [],
                        onChanged: (val) => setState(() => tempCity = val),
                      ),
                    ],
                  ),
                ),
              ),

              // Tombol Apply
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    // Kirim data ke Provider
                    provider.applyFilters(
                      sport: tempSport,
                      skill: tempSkill,
                      city: tempCity,
                    );
                    Navigator.pop(context); // Tutup modal
                  },
                  child: const Text("Apply Filters"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<Map<String, String>> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: (value != null && value!.isNotEmpty) ? value : null,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          hint: Text("Select $label"),
          items: [
            // Opsi Default (Kosong)
            const DropdownMenuItem(value: '', child: Text("All")),
            // Opsi dari API
            ...items.map((item) {
              return DropdownMenuItem<String>(
                value: item['value'],
                child: Text(item['label'] ?? '-'),
              );
            }),
          ],
          onChanged: onChanged,
        ),
      ],
    );
  }
}