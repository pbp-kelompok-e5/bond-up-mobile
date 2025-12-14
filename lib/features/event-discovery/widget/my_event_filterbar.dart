import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';


class FilterBarSection extends StatefulWidget {
  const FilterBarSection({super.key});

  @override
  State<FilterBarSection> createState() => _FilterBarSectionState();
}

class _FilterBarSectionState extends State<FilterBarSection> {
  // --- STATE VARIABLES ---
  String? _selectedStatus = 'all';
  final Set<String> _selectedSports = {};
  String _timeFilterType = 'all';
  DateTimeRange? _customDateRange;
  final Set<String> _selectedCities = {};

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
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
          _FilterChipButton(
            label: _selectedSports.isEmpty
                ? 'Semua Olahraga'
                : '${_selectedSports.length} Olahraga Dipilih',
            isActive: _selectedSports.isNotEmpty,
            onTap: () => _showSportFilter(context),
          ),
          const SizedBox(width: 8),
          _FilterChipButton(
            label: _getTimeFilterLabel(),
            isActive: true,
            onTap: () => _showTimeFilter(context),
          ),
          const SizedBox(width: 8),
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

  // Helper untuk label tombol waktu
  String _getTimeFilterLabel() {
    if (_timeFilterType == 'all') return 'Semua Tanggal';
    if (_timeFilterType == '30_days') return '30 Hari Terakhir';
    if (_customDateRange != null) {
      final start = DateFormat('dd MMM yyyy').format(_customDateRange!.start);
      final end = DateFormat('dd MMM yyyy').format(_customDateRange!.end);
      return '$start - $end';
    }
    return 'Rentang Waktu';
  }

  // --- MODAL BOTTOM SHEETS ---

  // 1. MODAL STATUS (RadioGroup)
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
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),

                  RadioGroup<String>(
                    groupValue: _selectedStatus,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedStatus = value);
                        setModalState(() {});
                        Navigator.pop(context);
                      }
                    },
                    child: Column(
                      children: const [
                        RadioListTile<String>(
                          title: Text('Semua Status'),
                          value: 'all',
                          contentPadding: EdgeInsets.zero,
                        ),
                        RadioListTile<String>(
                          title: Text('Event Akan Datang (Upcoming)'),
                          value: 'upcoming',
                          contentPadding: EdgeInsets.zero,
                        ),
                        RadioListTile<String>(
                          title: Text('Event Selesai (Finished)'),
                          value: 'finished',
                          contentPadding: EdgeInsets.zero,
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

  // 2. MODAL SPORT (Checkbox)
  void _showSportFilter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.6,
              maxChildSize: 0.9,
              minChildSize: 0.4,
              expand: false,
              builder: (_, controller) {
                return Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('Pilih Olahraga',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                      child: ListView.builder(
                        controller: controller,
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

  // 3. MODAL WAKTU (RadioGroup)
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
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),

                  RadioGroup<String>(
                    groupValue: _timeFilterType,
                    onChanged: (value) async {
                      if (value == null) return;

                      else if (value == '30_days' || value=='all') {
                        setState(() {
                          _timeFilterType = value;
                          _customDateRange = null;
                        });
                        setModalState(() {});
                        Navigator.pop(context);
                      } else if (value == 'custom') {
                        _openCustomDatePickerFlow(context, setModalState);
                      }
                    },
                    child: Column(
                      children: [
                        const RadioListTile<String>(
                          title: Text('Semua Tanggal Event'),
                          value: 'all',
                          contentPadding: EdgeInsets.zero,
                        ),
                        const RadioListTile<String>(
                          title: Text('30 Hari Terakhir'),
                          value: '30_days',
                          contentPadding: EdgeInsets.zero,
                        ),
                        RadioListTile<String>(
                          title: Text(_customDateRange == null
                              ? 'Pilih Rentang Tanggal'
                              : '${DateFormat('dd/MM/yyyy').format(_customDateRange!.start)} s/d ${DateFormat('dd/MM/yyyy').format(_customDateRange!.end)}'),
                          value: 'custom',
                          contentPadding: EdgeInsets.zero,
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

  // 4. MODAL KOTA (Checkbox)
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
            final filteredCities = AppConstants.sortedCities
                .where((element) => element.value.toLowerCase().contains(searchQuery.toLowerCase()))
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
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          TextField(
                            decoration: InputDecoration(
                              hintText: 'Cari kota...',
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                          final isSelected = _selectedCities.contains(city.key);
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
  // --- LOGIKA DATE PICKER CUSTOM (GAYA WHEEL / SEPERTI GAMBAR) ---

  // Flow: Pilih Mulai -> Pilih Selesai
  Future<void> _openCustomDatePickerFlow(BuildContext context, StateSetter setModalState) async {
    // Set type to 'custom' first before opening pickers
    setState(() => _timeFilterType = 'custom');
    setModalState(() {});

    // 1. Pilih Tanggal Mulai
    final start = await _showWheelDatePicker(
      context,
      title: "Mulai dari",
      initialDate: _customDateRange?.start ?? DateTime.now(),
    );
    if (start == null) return; // User batal

    // 2. Pilih Tanggal Selesai (Must be after start date)
    if (!mounted) return;
    final end = await _showWheelDatePicker(
      context,
      title: "Sampai tanggal",
      initialDate: _customDateRange?.end ?? start,
      minimumDate: start,
    );

    if (end != null) {
      setState(() {
        _customDateRange = DateTimeRange(start: start, end: end);
      });
      setModalState(() {});
      // Tutup modal utama filter setelah selesai
      Navigator.pop(context);
    }
  }

  // Widget BottomSheet Picker (Wheel Style)
  Future<DateTime?> _showWheelDatePicker(BuildContext context, {
    required String title,
    DateTime? initialDate,
    DateTime? minimumDate,
  }) {
    DateTime tempPickedDate = initialDate ?? DateTime.now();

    return showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext builder) {
        return SizedBox(
          height: 350, // Tinggi area picker
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Tombol Close & Judul
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(null),
                    ),
                    Text(
                      title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 48), // Spacer penyeimbang layout
                  ],
                ),
              ),

              // Garis pemisah
              const Divider(height: 1),

              // AREA PICKER (CUPERTINO / WHEEL)
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: tempPickedDate,
                  minimumDate: minimumDate ?? DateTime(2020),
                  maximumDate: DateTime(2030),
                  onDateTimeChanged: (DateTime newDate) {
                    tempPickedDate = newDate;
                  },
                ),
              ),

              // Tombol PILIH (Hijau)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, // Warna hijau sesuai gambar
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(tempPickedDate);
                    },
                    child: const Text(
                      'Pilih',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}


class _FilterChipButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChipButton({required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.green.shade50 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isActive ? Colors.green : Colors.grey.shade300),
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
            Icon(Icons.keyboard_arrow_down, size: 18, color: isActive ? Colors.green.shade700 : Colors.black54),
          ],
        ),
      ),
    );
  }
}

