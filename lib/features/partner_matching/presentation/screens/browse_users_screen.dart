import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bond_up_mobile/core/design_system.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  void _loadInitialData() {
    context.read<BrowseUsersProvider>().searchUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<BrowseUsersProvider>().searchUsers(query: query);
    });
  }

  Future<void> _onRefresh() async {
    await context.read<BrowseUsersProvider>().searchUsers(
          query: _searchController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BrowseUsersProvider>();

    return Scaffold(
      backgroundColor: AppColors.gray800,
      appBar: AppBar(
        title: const Text("Find Partners"),
        backgroundColor: AppColors.deepSea,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
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
          // Search Bar 
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.deepSea,
            child: Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: _searchController,
                    hint: "Search by name...",
                    onChanged: _onSearchChanged,
                  ),
                ),
                
                // Search Icon Button
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.orangeSport,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.search, color: Colors.white),
                    onPressed: () {
                      context.read<BrowseUsersProvider>().searchUsers(
                        query: _searchController.text,
                      );
                    },
                  ),
                ),
              ],
            )
          ),

          // Content Area
          Expanded(
            child: Builder(
              builder: (context) {
                if (provider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.orangeSport,
                    ),
                  );
                }

                if (provider.errorMessage.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: AppColors.buttonDanger,
                          size: 60,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Error: ${provider.errorMessage}",
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        AppButton(
                          text: "Retry",
                          size: ButtonSize.small,
                          onPressed: _loadInitialData,
                        ),
                      ],
                    ),
                  );
                }

                if (provider.users.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No users found",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Try adjusting your search or filters",
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  color: AppColors.orangeSport,
                  onRefresh: _onRefresh,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.users.length,
                    itemBuilder: (context, index) {
                      final user = provider.users[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: DeepSeaCard(
                          body: UserCard(user: user),
                          onTap: () {
                            // Navigate to user detail
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}