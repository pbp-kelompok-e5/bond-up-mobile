import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:bond_up_mobile/features/event-discovery/data/models/event_model.dart';
import 'package:bond_up_mobile/features/event-discovery/data/services/event_discovery_service.dart';
import 'package:bond_up_mobile/features/event-discovery/widget/my_event_filterbar.dart';
import 'package:bond_up_mobile/features/event-discovery/screens/event_detail.page.dart';
import 'package:bond_up_mobile/core/widgets/navigation/app_drawer.dart';
// Import AppColors untuk konsistensi warna
import '../../../core/theme/app_colors.dart';
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

  Future<void> _fetchMyEvents() async {
    try {
      final request = context.read<CookieRequest>();
      final events = await _service.fetchMyEvents(request);

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
        bool statusMatch = true;
        if (_currentFilter.status == 'upcoming') {
          statusMatch = event.eventDate.isAfter(now) || isSameDay(event.eventDate, now);
        } else if (_currentFilter.status == 'finished') {
          statusMatch = event.eventDate.isBefore(now) && !isSameDay(event.eventDate, now);
        }

        bool sportMatch = true;
        if (_currentFilter.sports.isNotEmpty) {
          sportMatch = _currentFilter.sports.contains(event.sportType);
        }

        bool cityMatch = true;
        if (_currentFilter.cities.isNotEmpty) {
          cityMatch = _currentFilter.cities.contains(event.city);
        }

        bool timeMatch = true;
        if (_currentFilter.timeType == '30_days') {
          final thirtyDaysAgo = now.subtract(const Duration(days: 30));
          timeMatch = event.eventDate.isAfter(thirtyDaysAgo);
        } else if (_currentFilter.timeType == 'custom' && _currentFilter.customDateRange != null) {
          final start = _currentFilter.customDateRange!.start;
          final end = _currentFilter.customDateRange!.end.add(const Duration(days: 1));
          timeMatch = event.eventDate.isAfter(start) && event.eventDate.isBefore(end);
        }

        return statusMatch && sportMatch && cityMatch && timeMatch;
      }).toList();
    });
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Menyamakan styling dengan EventDiscoveryScreen
        backgroundColor: AppColors.deepSea,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: AppColors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        title: const Text("My Events"),
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          FilterBarSection(
            onFilterChanged: _handleFilterChanged,
          ),
          const Divider(height: 1),
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
              _fetchMyEvents();
            },
            child: const Text("Muat Ulang"),
          )
        ],
      ),
    );
  }
}