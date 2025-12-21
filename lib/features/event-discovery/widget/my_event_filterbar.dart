import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import 'package:intl/intl.dart';
import 'package:bond_up_mobile/core/theme/app_colors.dart';

// Class untuk menampung state filter
class FilterData {
  final String status;
  final Set<String> sports;
  final String timeType;
  final DateTimeRange? customDateRange;
  final Set<String> cities;

  FilterData({
    required this.status,
    required this.sports,
    required this.timeType,
    this.customDateRange,
    required this.cities,
  });
}

class FilterBarSection extends StatefulWidget {
  final Function(FilterData) onFilterChanged; // Callback ke parent

  const FilterBarSection({super.key, required this.onFilterChanged});
  @override
  State<FilterBarSection> createState() => _FilterBarSectionState();
}

class _FilterBarSectionState extends State<FilterBarSection> {
  // --- STATE VARIABLES ---
  String _selectedStatus = 'all';
  final Set<String> _selectedSports = {};
  String _timeFilterType = 'all';
  DateTimeRange? _customDateRange;
  final Set<String> _selectedCities = {};

  // Fungsi helper untuk mengirim data terbaru ke MyEventPage
  void _notifyChange() {
    widget.onFilterChanged(FilterData(
      status: _selectedStatus,
      sports: _selectedSports,
      timeType: _timeFilterType,
      customDateRange: _customDateRange,
      cities: _selectedCities,
    ));
  }

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
            isActive: _selectedStatus == 'all' ? false : true,
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
            isActive: _timeFilterType == 'all' ? false : true,
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
      backgroundColor: AppColors.darkGrayBackground,
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
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 16),

                  RadioGroup<String>(
                    groupValue: _selectedStatus,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedStatus = value);
                        setModalState(() {});
                        _notifyChange();
                        Navigator.pop(context);
                      }
                    },
                    child: Column(
                      children: const [
                        RadioListTile<String>(
                          title: Text('Semua Status', style: TextStyle(color: Colors.white)),
                          value: 'all',
                          activeColor: AppColors.orangeSport,
                          contentPadding: EdgeInsets.zero,
                        ),
                        RadioListTile<String>(
                          title: Text('Event Akan Datang (Upcoming)', style: TextStyle(color: Colors.white)),
                          value: 'upcoming',
                          activeColor: AppColors.orangeSport,
                          contentPadding: EdgeInsets.zero,
                        ),
                        RadioListTile<String>(
                          title: Text('Event Selesai (Finished)', style: TextStyle(color: Colors.white)),
                          value: 'finished',
                          activeColor: AppColors.orangeSport,
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
      backgroundColor: AppColors.darkGrayBackground,
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
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                    Expanded(
                      child: ListView.builder(
                        controller: controller,
                        itemCount: AppConstants.sortedSports.length,
                        itemBuilder: (context, index) {
                          final sport = AppConstants.sortedSports[index];
                          final isSelected = _selectedSports.contains(sport.key);
                          return CheckboxListTile(
                            title: Text(sport.value, style: const TextStyle(color: Colors.white)),
                            activeColor: AppColors.orangeSport,
                            side: const BorderSide(color: Colors.white24),
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
                              _notifyChange();
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
      backgroundColor: AppColors.darkGrayBackground,
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
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 16),

                  RadioGroup<String>(
                    groupValue: _timeFilterType,
                    onChanged: (value) async {
                      if (value == null) {
                        return;
                      } else if (value == '30_days' || value=='all') {
                        setState(() {
                          _timeFilterType = value;
                          _customDateRange = null;
                        });
                        setModalState(() {});
                        _notifyChange();
                        Navigator.pop(context);
                      } else if (value == 'custom') {
                        _openCustomDatePickerFlow(context, setModalState);
                      }
                    },
                    child: Column(
                      children: [
                        const RadioListTile<String>(
                          title: Text('Semua Tanggal Event', style: TextStyle(color: Colors.white)),
                          value: 'all',
                          activeColor: AppColors.orangeSport,
                          contentPadding: EdgeInsets.zero,
                        ),
                        const RadioListTile<String>(
                          title: Text('30 Hari Terakhir', style: TextStyle(color: Colors.white)),
                          value: '30_days',
                          activeColor: AppColors.orangeSport,
                          contentPadding: EdgeInsets.zero,
                        ),
                        RadioListTile<String>(
                          title: Text(_customDateRange == null
                              ? 'Pilih Rentang Tanggal'
                              : '${DateFormat('dd/MM/yyyy').format(_customDateRange!.start)} s/d ${DateFormat('dd/MM/yyyy').format(_customDateRange!.end)}'
                              , style: const TextStyle(color: Colors.white)),
                          value: 'custom',
                          activeColor: AppColors.orangeSport,
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
      backgroundColor: AppColors.darkGrayBackground,
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
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                          const SizedBox(height: 12),
                          TextField(
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Cari kota...',
                              hintStyle: const TextStyle(color: Colors.white38),
                              prefixIcon: const Icon(Icons.search, color: AppColors.orangeSport,),
                              fillColor: AppColors.deepSea,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
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
                          final isSelected = _selectedCities.contains(city.key);
                          return CheckboxListTile(
                            title: Text(city.value, style: const TextStyle(color: Colors.white)),
                            activeColor: AppColors.orangeSport,
                            side: const BorderSide(color: Colors.white24),
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
                              _notifyChange();
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

  // Flow: Menggunakan showDateRangePicker bawaan Flutter
  Future<void> _openCustomDatePickerFlow(
      BuildContext context, StateSetter setModalState) async {

    // Tampilkan Full Screen Date Range Picker
    final DateTimeRange? pickedRange = await showDateRangePicker(
      context: context,
      initialDateRange: _customDateRange,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      // Builder untuk mengubah tema warna agar sesuai
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.orangeSport, // Warna Header & Seleksi
              onPrimary: Colors.white, // Warna Teks di Header
              onSurface: Colors.white, // Warna Teks Tanggal
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.orangeSport,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (!context.mounted) return;
    
    // Jika user memilih tanggal (tidak cancel)
    if (pickedRange != null) {
      setState(() {
        _timeFilterType = 'custom';
        _customDateRange = pickedRange;
      });

      // Update tampilan modal bottom sheet (agar radio button 'custom' terupdate teksnya)
      setModalState(() {});
      _notifyChange();

      // Opsi: Langsung tutup bottom sheet setelah memilih tanggal agar user langsung lihat hasil filter
      Navigator.pop(context);
    }
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
          color: isActive ? AppColors.deepSea.withValues(alpha: 0.8) : AppColors.deepSea.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isActive ? AppColors.orangeSport : AppColors.orangeSport),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isActive ? AppColors.orangeSport : AppColors.orangeSport,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down, size: 18, color: AppColors.orangeSport,
            )],
        ),
      ),
    );
  }
}

