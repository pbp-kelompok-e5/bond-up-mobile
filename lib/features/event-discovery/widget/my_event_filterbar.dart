import 'package:flutter/material.dart';
import 'package:bond_up_mobile/app/app_theme.dart';
import '../../../core/constants/app_constants.dart';

class FilterBarSection extends StatefulWidget {
  const FilterBarSection({Key? key}) : super(key: key);

  @override
  State<FilterBarSection> createState() => _FilterBarSectionState();
}

class _FilterBarSectionState extends State<FilterBarSection> {
  // --- STATE VARIABLES ---

  // 1. Event Status (Radio Button)
  String? _selectedStatus = 'all'; // Default: upcoming

  // 2. Sport Choices (Checkbox List)
  final Set<String> _selectedSports = {};

  // 3. Time Filter (Radio + Date Range)
  String _timeFilterType = '30_days'; // '30_days' or 'custom'
  DateTimeRange? _customDateRange;

  // 4. City Filter (Checkbox + Search)
  final Set<String> _selectedCities = {};

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // TOMBOL FILTER STATUS
          _FilterChipButton(
            label: _selectedStatus == 'upcoming'
                ? 'Event Akan Datang'
                : _selectedStatus == 'finished'
                ? 'Event Selesai'
                : 'Semua Status',
            isActive: true,
            onTap: () => _showStatusFilter(context),
          ),
          const SizedBox(width: 8),

          // TOMBOL FILTER SPORT
          _FilterChipButton(
            label: _selectedSports.isEmpty
                ? 'Semua Olahraga'
                : '${_selectedSports.length} Olahraga Dipilih',
            isActive: _selectedSports.isNotEmpty,
            onTap: () => _showSportFilter(context),
          ),
          const SizedBox(width: 8),

          // TOMBOL FILTER WAKTU
          _FilterChipButton(
            label: _timeFilterType == '30_days'
                ? '30 Hari Terakhir'
                : _customDateRange != null
                ? '${_customDateRange!.start.day}/${_customDateRange!.start.month} - ${_customDateRange!.end.day}/${_customDateRange!.end.month}'
                : 'Rentang Waktu',
            isActive: true,
            onTap: () => _showTimeFilter(context),
          ),
          const SizedBox(width: 8),

          // TOMBOL FILTER KOTA
          _FilterChipButton(
            label: _selectedCities.isEmpty
                ? 'Semua Kota'
                : '${_selectedCities.length} Kota Dipilih',
            isActive: _selectedCities.isNotEmpty,
            onTap: () => _showCityFilter(context),
          ),
        ],
      ),
    );
  }

  // --- MODAL BOTTOM SHEETS ---

  // 1. MODAL STATUS (Radio Button)
  void _showStatusFilter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('Pilih Status Event',
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 1024),
                  RadioGroup<String>(
                    groupValue: _selectedStatus,
                    onChanged: (value) {
                      setState(() => _selectedStatus = value);
                      setModalState(() {});
                      Navigator.pop(context);
                    },
                    child: const Column(
                      children: [
                        RadioListTile<String>(
                          title: const Text('Upcoming Event'),
                          value: 'upcoming',
                        ),
                        RadioListTile<String>(
                          title: const Text('Finished Event'),
                          value: 'finished',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 2. MODAL SPORT (Diperbaiki: Memastikan List Render Semua Item)
  void _showSportFilter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Penting agar bisa full screen
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.6, // Ukuran awal modal
              maxChildSize: 0.9,
              minChildSize: 0.4,
              expand: false,
              builder: (_, controller) {
                return Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('Pilih Olahraga',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                      child: ListView.builder(
                        controller: controller,
                        // Pastikan mengambil length dari sortedSports
                        itemCount: AppConstants.sortedSports.length,
                        itemBuilder: (context, index) {
                          final sport = AppConstants.sortedSports[index];
                          final isSelected = _selectedSports.contains(sport.key);

                          return CheckboxListTile(
                            title: Text(sport.value),
                            value: isSelected,
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  _selectedSports.add(sport.key);
                                } else {
                                  _selectedSports.remove(sport.key);
                                }
                              });
                              setModalState(() {});
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  // 3. MODAL WAKTU (Radio + Date Picker)
  void _showTimeFilter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Filter Waktu',
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  RadioListTile<String>(
                    title: const Text('30 Hari Terakhir'),
                    value: '30_days',
                    groupValue: _timeFilterType,
                    onChanged: (value) {
                      setState(() {
                        _timeFilterType = value!;
                        _customDateRange = null;
                      });
                      setModalState(() {});
                      Navigator.pop(context);
                    },
                  ),
                  RadioListTile<String>(
                    title: Text(_customDateRange == null
                        ? 'Pilih Rentang Tanggal'
                        : '${_customDateRange!.start.toString().split(' ')[0]} s/d ${_customDateRange!.end.toString().split(' ')[0]}'),
                    value: 'custom',
                    groupValue: _timeFilterType,
                    onChanged: (value) async {
                      // Buka Date Picker
                      final picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                        initialDateRange: _customDateRange,
                      );
                      if (picked != null) {
                        setState(() {
                          _timeFilterType = 'custom';
                          _customDateRange = picked;
                        });
                        setModalState(() {});
                        Navigator.pop(context); // Tutup modal setelah pilih
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 4. MODAL KOTA (Checkbox + Search Bar)
  void _showCityFilter(BuildContext context) {
    String searchQuery = "";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            // Filter list kota berdasarkan pencarian
            final filteredCities = AppConstants.sortedCities
                .where((element) => element.value
                .toLowerCase()
                .contains(searchQuery.toLowerCase()))
                .toList();

            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              maxChildSize: 0.9,
              expand: false,
              builder: (_, controller) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Pilih Kota',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          // Input Pencarian
                          TextField(
                            decoration: InputDecoration(
                              hintText: 'Cari kota...',
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                            ),
                            onChanged: (val) {
                              setModalState(() {
                                searchQuery = val;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        controller: controller,
                        itemCount: filteredCities.length,
                        itemBuilder: (context, index) {
                          final city = filteredCities[index];
                          final isSelected =
                          _selectedCities.contains(city.key);
                          return CheckboxListTile(
                            title: Text(city.value),
                            value: isSelected,
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  _selectedCities.add(city.key);
                                } else {
                                  _selectedCities.remove(city.key);
                                }
                              });
                              setModalState(() {});
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}

// --- WIDGET TOMBOL FILTER (Styling seperti gambar) ---
class _FilterChipButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChipButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.green.shade50 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20), // Membuat rounded
          border: Border.all(
            color: isActive ? Colors.green : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.green.shade700 : Colors.black87,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: isActive ? Colors.green.shade700 : Colors.black54,
            ),
          ],
        ),
      ),
    );
  }
}