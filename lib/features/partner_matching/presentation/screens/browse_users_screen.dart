import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/browse_users_provider.dart';
import '../widgets/user_card.dart';
import '../widgets/filter_bottom_sheet.dart';

class BrowseUsersScreen extends StatefulWidget {
  const BrowseUsersScreen({super.key});

  @override
  State<BrowseUsersScreen> createState() => _BrowseUsersScreenState();
}

class _BrowseUsersScreenState extends State<BrowseUsersScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Panggil fetch data pertama kali saat layar dibuka
    // Gunakan Future.microtask agar tidak error saat build belum selesai
    Future.microtask(() {
      context.read<BrowseUsersProvider>().searchUsers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // Fungsi Debounce biar gak spam API saat ngetik
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      // Panggil fungsi search di Provider
      context.read<BrowseUsersProvider>().searchUsers(query: query);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch: Akan rebuild halaman ini setiap kali ada perubahan di Provider (loading/data baru)
    final provider = context.watch<BrowseUsersProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Find Partners"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true, // Biar bisa tinggi
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (context) => const FilterBottomSheet(),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.indigo,
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: "Search by name...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<BrowseUsersProvider>().searchUsers(query: '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          // 2. Content Area (Loading / Error / List)
          Expanded(
            child: Builder(
              builder: (context) {
                // Skenario 1: Loading
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Skenario 2: Error
                if (provider.errorMessage.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 60),
                        const SizedBox(height: 16),
                        Text("Error: ${provider.errorMessage}"),
                        ElevatedButton(
                          onPressed: () {
                            context.read<BrowseUsersProvider>().searchUsers();
                          },
                          child: const Text("Retry"),
                        )
                      ],
                    ),
                  );
                }

                // Skenario 3: Data Kosong
                if (provider.users.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          "No users found",
                          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                // Skenario 4: Ada Data (Tampilkan List)
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.users.length,
                  itemBuilder: (context, index) {
                    final user = provider.users[index];
                    return UserCard(user: user);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Contoh implementasi filter modal singkat
  void _showFilterModal(BuildContext context) {
      // Implementasi BottomSheet filter kamu di sini
      // Saat tombol "Apply" ditekan, panggil:
      // context.read<BrowseUsersProvider>().searchUsers(sport: 'football', city: 'Jakarta');
  }
}