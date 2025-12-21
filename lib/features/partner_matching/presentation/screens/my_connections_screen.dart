import 'package:bond_up_mobile/features/partner_matching/data/models/user_match_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bond_up_mobile/core/design_system.dart'; 
import '../../logic/connections_provider.dart';
import '../widgets/user_card.dart'; 

class MyConnectionsScreen extends StatefulWidget {
  const MyConnectionsScreen({super.key});

  @override
  State<MyConnectionsScreen> createState() => _MyConnectionsScreenState();
}

class _MyConnectionsScreenState extends State<MyConnectionsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConnectionsProvider>().loadConnections();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AppColors.gray800,
        appBar: AppBar(
          title: const Text("My Connections"),
          backgroundColor: AppColors.deepSea,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.center,
            labelColor: AppColors.orangeSport,
            unselectedLabelColor: Colors.white60,
            indicatorColor: AppColors.orangeSport,
            dividerColor: Colors.transparent,
            tabs: [
              Tab(text: "Friends"),
              Tab(text: "Received"),
              Tab(text: "Sent"),
              Tab(text: "Recommendations"),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => context.read<ConnectionsProvider>().loadConnections(),
            ),
          ],
        ),
        body: Consumer<ConnectionsProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.orangeSport),
              );
            }

            if (provider.errorMessage.isNotEmpty) {
              return Center(
                child: Text(
                  "Error: ${provider.errorMessage}", 
                  style: const TextStyle(color: Colors.white),
                )
              );
            }

            return TabBarView(
              children: [
                _buildList(provider.myFriends, "No friends yet", "remove", "Remove"),
                _buildReceivedList(provider.receivedRequests),
                _buildList(provider.sentRequests, "No sent requests", "cancel", "Cancel"),
                _buildList(provider.recommendations, "No suggestions", "connect", "Connect"),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildList(List<UserMatchModel> users, String emptyMsg, String action, String btnLabel) {
    if (users.isEmpty) {
      return Center(
        child: Text(
          emptyMsg, 
          style: const TextStyle(color: Colors.white54, fontSize: 16),
        ),
      );
    }

    return ListView.separated(
      itemCount: users.length,
      padding: const EdgeInsets.all(16),
      // Jarak 16 pixel antar item
      separatorBuilder: (context, index) => const SizedBox(height: 16), 
      itemBuilder: (context, index) {
        final user = users[index];
        
        ButtonVariant variant = ButtonVariant.primary;
        if (action == 'remove' || action == 'cancel') {
          variant = ButtonVariant.danger;
        } else if (action == 'connect') {
          variant = ButtonVariant.primary;
        }

        return DeepSeaCard(
          body: Column(
            children: [
              UserCard(user: user), 
              const SizedBox(height: 12),
              AppButton(
                text: btnLabel,
                variant: variant,
                isFullWidth: true,
                // Tombol Small
                size: ButtonSize.small, 
                onPressed: () {
                  context.read<ConnectionsProvider>().handleAction(action, user.id);
                },
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildReceivedList(List<UserMatchModel> users) {
    if (users.isEmpty) {
      return const Center(
        child: Text(
          "No friend requests",
          style: TextStyle(color: Colors.white54, fontSize: 16),
        ),
      );
    }

    // Pake ListView.separated
    return ListView.separated(
      itemCount: users.length,
      padding: const EdgeInsets.all(16),
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final user = users[index];
        
        return DeepSeaCard(
          body: Column(
            children: [
              UserCard(user: user),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: "Accept",
                      variant: ButtonVariant.success,
                      size: ButtonSize.small, // Ukuran kecil
                      onPressed: () {
                        context.read<ConnectionsProvider>().handleAction('accept', user.id);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      text: "Reject",
                      variant: ButtonVariant.danger,
                      size: ButtonSize.small, // Ukuran Kecil
                      onPressed: () {
                        context.read<ConnectionsProvider>().handleAction('reject', user.id);
                      },
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }
}