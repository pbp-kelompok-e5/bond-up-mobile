import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:bond_up_mobile/features/event-discovery/data/models/event_model.dart';
import 'package:bond_up_mobile/features/event-discovery/data/services/event_discovery_service.dart';
import 'package:bond_up_mobile/features/event-discovery/widget/disc_event_filterbar.dart';
import 'package:bond_up_mobile/features/event-discovery/screens/event_detail.page.dart';
import 'package:bond_up_mobile/core/widgets/navigation/app_drawer.dart';
import 'package:bond_up_mobile/features/event-discovery/screens/event_search_page.dart';
import '../widget/event_tile.dart';

class EventDiscoveryScreen extends StatefulWidget{
  final String? initialSport;
  const EventDiscoveryScreen({super.key, this.initialSport});

  @override
  State<EventDiscoveryScreen> createState() => _EventDiscoveryScreenState();
}

class _EventDiscoveryScreenState extends State<EventDiscoveryScreen>{
  // State Data
  late EventDiscoveryService _service;
  List<Event> _allEvents = [];
  List<Event> _filteredEvents = [];
  bool _isLoading = true;

  // State Filter (Default)
  late FilterData _currentFilter;

  // State Search
  String _searchQuery = ""; // Tambahan untuk menyimpan query pencarian

  @override
  void initState() {
    super.initState();
    final request = context.read<CookieRequest>();
    _service = EventDiscoveryService(request);
    _currentFilter = FilterData(
      sports: widget.initialSport != null ? {widget.initialSport!} : {},
      timeType: 'all',
      cities: {},
    );

    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    try {
      final request = context.read<CookieRequest>();
      // Menggunakan service fetchEvents
      final events = await _service.fetchEvents(request);

      if (mounted) {
        setState(() {
          _allEvents = events;
          _isLoading = false;
        });
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

        // 1. Filter Pencarian (Search Bar)
        bool searchMatch = true;
        if (_searchQuery.isNotEmpty) {
          // PERBAIKAN: Menggunakan event.title sesuai model
          // Menggunakan toLowerCase() agar pencarian tidak sensitif huruf besar/kecil
          searchMatch = event.title.toLowerCase().contains(_searchQuery.toLowerCase());
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
        if (_currentFilter.timeType == '7_days') {
          final sevenDays = now.add(const Duration(days: 8));
          timeMatch = event.eventDate.isAfter(now) && event.eventDate.isBefore(sevenDays);
        } else if (_currentFilter.timeType == 'custom' && _currentFilter.customDateRange != null) {
          final start = _currentFilter.customDateRange!.start;
          final end = _currentFilter.customDateRange!.end.add(const Duration(days: 1)); // Include end day
          timeMatch = event.eventDate.isAfter(start) && event.eventDate.isBefore(end);
        }

        return searchMatch && sportMatch && cityMatch && timeMatch;
      }).toList();
    });
  }

  // Fungsi untuk navigasi ke halaman Search
  Future<void> _navigateToSearch() async {
    // Navigator.push mengembalikan hasil dari Navigator.pop di halaman sebelah
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EventSearchPage()),
    );

    // Jika user menekan enter atau memilih history, result tidak null
    if (result != null && result is String) {
      setState(() {
        _searchQuery = result;
      });
      _applyFilters(); // Terapkan filter ulang
    }
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
        title: _buildSearchBar(),
        actions: [
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _searchQuery = ""; // Kosongkan query
                });
                _applyFilters(); // Refresh list
              },
            ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // 1. FILTER BAR
          FilterBarSection(
            initialSportType: widget.initialSport,
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
              onRefresh: _fetchEvents,
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

  // Widget Search Bar di AppBar
  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: _navigateToSearch,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            const Icon(Icons.search, color: Colors.grey),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _searchQuery.isEmpty ? "Cari event..." : _searchQuery,
                style: TextStyle(
                  color: _searchQuery.isEmpty ? Colors.grey : Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.normal, // Override style AppBar
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
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
              _fetchEvents();
            },
            child: const Text("Muat Ulang"),
          )
        ],
      ),
    );
  }
}