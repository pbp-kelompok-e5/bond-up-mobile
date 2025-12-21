import 'package:flutter/material.dart';
import 'package:bond_up_mobile/features/event-discovery/screens/event_discovery_page.dart';
import 'package:bond_up_mobile/core/theme/app_colors.dart';

class EventSearchPage extends StatefulWidget {
  final bool fromDiscovery;
  const EventSearchPage({super.key, this.fromDiscovery = false});

  @override
  State<EventSearchPage> createState() => _EventSearchPageState();
}

class _EventSearchPageState extends State<EventSearchPage> {
  final TextEditingController _searchController = TextEditingController();

  static List<String> searchHistory = [];

  void _onSearchSubmitted(String query) {
    if (query.trim().isEmpty) return;

    setState(() {
      searchHistory.remove(query);
      searchHistory.insert(0, query);
      if (searchHistory.length > 10) {
        searchHistory.removeLast();
      }
    });

    if (widget.fromDiscovery) {
      Navigator.pop(context, query);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => EventDiscoveryScreen(initialSearchQuery: query),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Menggunakan warna background abu-abu gelap seperti EventHistory
      backgroundColor: AppColors.darkGrayBackground,
      appBar: AppBar(
        backgroundColor: AppColors.deepSea,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          // Mengubah warna teks input menjadi putih
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Cari event apa?",
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
          ),
          textInputAction: TextInputAction.search,
          onSubmitted: _onSearchSubmitted,
        ),
      ),
      body: Container(
        // Memastikan container mengikuti warna background utama
        color: AppColors.darkGrayBackground,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Riwayat Pencarian",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white, // Teks judul menjadi putih
              ),
            ),
            const SizedBox(height: 16),
            if (searchHistory.isEmpty)
              Text(
                "Belum ada riwayat pencarian",
                style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
              )
            else
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: searchHistory.map((historyItem) {
                  return ActionChip(
                    label: Text(historyItem),
                    labelStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    // Menggunakan warna Deep Sea untuk background chip
                    backgroundColor: AppColors.deepSea,
                    // Border menggunakan warna Orange Sport agar senada dengan UI utama
                    side: BorderSide(
                      color: AppColors.orangeSport.withValues(alpha: 0.5),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    onPressed: () {
                      _onSearchSubmitted(historyItem);
                    },
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}