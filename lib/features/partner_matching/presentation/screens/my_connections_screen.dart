import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/connections_provider.dart';
import '../widgets/user_card.dart';
import '../../data/model/user_match_model.dart';

class MyConnectionsScreen extends StatefulWidget {
  const MyConnectionsScreen({super.key});

  @override
  State<MyConnectionsScreen> createState() => _MyConnectionsScreenState();
}

class _MyConnectionsScreenState extends State<MyConnectionsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch data ketika layar dibuka
    Future.microtask(() => context.read<ConnectionsProvider>().loadConnections());
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, // Jumlah Tab
      child: Scaffold(
        appBar: AppBar(
          title: const Text("My Connections"),
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            isScrollable: true, // Agar tab bisa discroll kalau kebanyakan
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.orange,
            tabs: [
              Tab(text: "Friends"),
              Tab(text: "Received"),
              Tab(text: "Sent"),
              Tab(text: "Suggestions"),
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
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.errorMessage.isNotEmpty) {
              return Center(child: Text("Error: ${provider.errorMessage}"));
            }

            return TabBarView(
              children: [
                // 1. Tab Friends (Tombol Remove)
                _buildList(provider.myFriends, "No friends yet", "remove", "Remove"),
                
                // 2. Tab Received (Tombol Accept & Reject)
                _buildReceivedList(provider.receivedRequests),
                
                // 3. Tab Sent (Tombol Cancel)
                _buildList(provider.sentRequests, "No sent requests", "cancel", "Cancel"),
                
                // 4. Tab Suggestions (Tombol Connect)
                _buildList(provider.recommendations, "No suggestions", "connect", "Connect"),
              ],
            );
          },
        ),
      ),
    );
  }

  // Widget untuk List Standar (1 Tombol)
  Widget _buildList(List<UserMatchModel> users, String emptyMsg, String action, String btnLabel) {
    if (users.isEmpty) return Center(child: Text(emptyMsg));

    return ListView.builder(
      itemCount: users.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final user = users[index];
        // UserCard menggunakan Column agar bisa ditambahkan tombol di bawahnya
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            children: [
              UserCard(user: user), // UserCard di atas
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: action == 'remove' || action == 'cancel' ? Colors.red[50] : Colors.blue[50],
                      foregroundColor: action == 'remove' || action == 'cancel' ? Colors.red : Colors.blue,
                    ),
                    onPressed: () {
                      context.read<ConnectionsProvider>().handleAction(action, user.id);
                    },
                    child: Text(btnLabel),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  // Widget Khusus Tab Received (2 Tombol: Accept & Reject)
  Widget _buildReceivedList(List<UserMatchModel> users) {
    if (users.isEmpty) return const Center(child: Text("No friend requests"));

    return ListView.builder(
      itemCount: users.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final user = users[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            children: [
              UserCard(user: user),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                        onPressed: () {
                          context.read<ConnectionsProvider>().handleAction('accept', user.id);
                        },
                        child: const Text("Accept"),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                        onPressed: () {
                          context.read<ConnectionsProvider>().handleAction('reject', user.id);
                        },
                        child: const Text("Reject"),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}