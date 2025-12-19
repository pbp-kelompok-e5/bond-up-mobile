import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:bond_up_mobile/core/design_system.dart';
import 'package:bond_up_mobile/features/event-discovery/data/models/event_model.dart';
import 'package:bond_up_mobile/features/event-discovery/data/services/event_discovery_service.dart';
import 'package:bond_up_mobile/main.dart';
import 'package:bond_up_mobile/features/event-discovery/widget/my_event_filterbar.dart';
import 'package:bond_up_mobile/features/event-discovery/screens/event_detail.page.dart';
import 'package:bond_up_mobile/core/widgets/navigation/app_drawer.dart';
import 'package:bond_up_mobile/features/auth/data/services/auth_service.dart';
import 'package:bond_up_mobile/features/auth/presentation/screens/login_screen.dart';

import '../widget/event_tile.dart';

class MyEventScreen extends StatefulWidget{
  const MyEventScreen({super.key});

  @override
  State<MyEventScreen> createState() => _MyEventScreen();
}

class _MyEventScreen extends State<MyEventScreen>{
  // State Data
  late EventDiscoveryService _service;
  List<Event> _allEvents = [];
  List<Event> _filteredEvents = [];
  bool _isLoading = true;

  // State Filter (Default)
  FilterData _currentFilter = FilterData(
    status: 'all',
    sports: {},
    timeType: 'all',
    cities: {},
  );

  @override
  void initState() {
    super.initState();
    final request = context.read<CookieRequest>();
    _service = EventDiscoveryService(request);
    _fetchMyEvents();
  }

  // Logout
  Future<void> _handleLogout() async {
    // Mengambil request dari provider
    final request = context.read<CookieRequest>();
    final authService = AuthService(request);

    // Melakukan logout ke backend
    await authService.logout();

    // Cek apakah widget masih aktif sebelum menggunakan context
    if (!mounted) return;

    // Menampilkan pesan sukses
    try {
      // Asumsi kamu punya class ToastUtils di design_system.dart
      ToastUtils.showSuccess(context, 'Logged out successfully');
    } catch (e) {
      // Fallback jika ToastUtils belum siap
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged out successfully')),
      );
    }

    // Navigasi kembali ke Login Screen dan menghapus history route sebelumnya
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  Future<void> _fetchMyEvents() async {
    try {
      final request = context.read<CookieRequest>();
      // Menggunakan service fetchMyEvents yang sudah Anda buat
      final events = await _service.fetchMyEvents(request);

      if (mounted) {
        setState(() {
          _allEvents = events;
          _filteredEvents = events; // Awalnya tampilkan semua
          _isLoading = false;
        });
        // Terapkan filter jika ada state filter tersimpan (opsional)
        _applyFilters();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat event: $e')),
        );
      }
    }
  }

  void _handleFilterChanged(FilterData newFilter) {
    setState(() {
      _currentFilter = newFilter;
    });
    _applyFilters();
  }

  void _applyFilters() {
    final now = DateTime.now();

    setState(() {
      _filteredEvents = _allEvents.where((event) {
        // 1. Filter Status (Upcoming vs Finished)
        // Logika sederhana: Berdasarkan Tanggal
        // Jika Anda punya field 'status' di model yang akurat, gunakan itu.
        // Di sini kita pakai logika tanggal sebagai fallback/utama.
        bool statusMatch = true;
        if (_currentFilter.status == 'upcoming') {
          // Tanggal event belum lewat
          statusMatch = event.eventDate.isAfter(now) || isSameDay(event.eventDate, now);
        } else if (_currentFilter.status == 'finished') {
          // Tanggal event sudah lewat
          statusMatch = event.eventDate.isBefore(now) && !isSameDay(event.eventDate, now);
        }

        // 2. Filter Olahraga
        bool sportMatch = true;
        if (_currentFilter.sports.isNotEmpty) {
          // Cek apakah sportType event ada di set yang dipilih
          // Pastikan case insensitive atau sesuaikan key-nya
          sportMatch = _currentFilter.sports.contains(event.sportType);
        }

        // 3. Filter Kota
        bool cityMatch = true;
        if (_currentFilter.cities.isNotEmpty) {
          cityMatch = _currentFilter.cities.contains(event.city);
        }

        // 4. Filter Waktu
        bool timeMatch = true;
        if (_currentFilter.timeType == '30_days') {
          // Misal: Event dalam 30 hari ke depan (atau ke belakang, tergantung konteks 'History')
          // Asumsi: My Joined Events biasanya untuk melihat jadwal ke depan atau history ke belakang.
          // Mari kita ambil: 30 hari ke belakang (history) s/d tak terbatas ke depan
          final thirtyDaysAgo = now.subtract(const Duration(days: 30));
          timeMatch = event.eventDate.isAfter(thirtyDaysAgo);
        } else if (_currentFilter.timeType == 'custom' && _currentFilter.customDateRange != null) {
          final start = _currentFilter.customDateRange!.start;
          final end = _currentFilter.customDateRange!.end.add(const Duration(days: 1)); // Include end day
          timeMatch = event.eventDate.isAfter(start) && event.eventDate.isBefore(end);
        }

        return statusMatch && sportMatch && cityMatch && timeMatch;
      }).toList();
    });
  }

  // Helper simple check same day
  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // UBAH WARNA DI SINI:
        // Gunakan warna primary agar lebih tegas sebagai background
        backgroundColor: Theme.of(context).colorScheme.primary,
        // foregroundColor memaksa semua text dan icon di AppBar (termasuk drawer) menjadi Putih
        foregroundColor: Colors.white,
        title: const Text("Event Detail"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            // Aksi saat tombol logout ditekan
            onPressed: _handleLogout,
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // 1. FILTER BAR
          FilterBarSection(
            onFilterChanged: _handleFilterChanged,
          ),
          const Divider(height: 1),

          // 2. LIST EVENT
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredEvents.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
              onRefresh: _fetchMyEvents,
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 80),
                itemCount: _filteredEvents.length,
                itemBuilder: (context, index) {
                  final event = _filteredEvents[index];
                  return EventCard(
                    event: event,
                    onTap: () async {
                      // Navigasi ke Detail
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EventDetailScreen(event: event),
                        ),
                      );
                      // Refresh saat kembali (jika user leave event)
                      _fetchMyEvents();
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            "Tidak ada event ditemukan",
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              // Reset filter logic here if needed or just fetch
              _fetchMyEvents();
            },
            child: const Text("Muat Ulang"),
          )
        ],
      ),
    );
  }
}
