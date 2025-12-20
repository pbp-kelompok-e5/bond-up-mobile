import 'package:flutter/material.dart';

class EventSearchPage extends StatefulWidget {
  const EventSearchPage({super.key});

  @override
  State<EventSearchPage> createState() => _EventSearchPageState();
}

class _EventSearchPageState extends State<EventSearchPage> {
  final TextEditingController _searchController = TextEditingController();

  // Menggunakan static agar history tersimpan selama aplikasi berjalan (tidak hilang saat back)
  // Jika ingin tersimpan permanen setelah restart, perlu pakai SharedPreferences.
  static List<String> searchHistory = [];

  void _onSearchSubmitted(String query) {
    if (query.trim().isEmpty) return;

    setState(() {
      // Hapus jika sudah ada (supaya pindah ke paling depan)
      searchHistory.remove(query);
      // Masukkan ke index 0 (paling awal)
      searchHistory.insert(0, query);
      // Batasi hanya 10 item
      if (searchHistory.length > 10) {
        searchHistory.removeLast();
      }
    });

    // Kembali ke halaman sebelumnya membawa hasil query
    Navigator.pop(context, query);
  }

  void _removeHistoryItem(String item) {
    setState(() {
      searchHistory.remove(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true, // Langsung muncul keyboard
          decoration: InputDecoration(
            hintText: "Cari event apa?",
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey.shade400),
          ),
          textInputAction: TextInputAction.search,
          onSubmitted: _onSearchSubmitted,
        ),
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Riwayat Pencarian",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            if (searchHistory.isEmpty)
              Text(
                "Belum ada riwayat pencarian",
                style: TextStyle(color: Colors.grey.shade500),
              )
            else
              Wrap(
                spacing: 8.0, // Jarak horizontal antar chip
                runSpacing: 4.0, // Jarak vertical antar baris
                children: searchHistory.map((historyItem) {
                  return ActionChip(
                    label: Text(historyItem),
                    labelStyle: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: Theme.of(context).primaryColor.withOpacity(0.5),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    onPressed: () {
                      // Jika chip ditekan, langsung cari
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