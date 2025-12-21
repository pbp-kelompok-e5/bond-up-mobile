import '../../../../core/widgets/navigation/app_drawer.dart';
import '../../../../core/design_system.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../auth/data/services/auth_service.dart';
import '../../../event-discovery/screens/event_public_detail_page.dart';
import '../../../event-discovery/services/event_discovery_service.dart';
import '../../../event-discovery/widgets/event_card.dart';
import '../../../event-management/models/event.dart';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<Event>> _eventsFuture;
  late EventDiscoveryService _eventService;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final request = context.watch<CookieRequest>();
    _eventService = EventDiscoveryService(request);
    _refreshEvents();
  }

  void _refreshEvents() {
    setState(() {
      _eventsFuture = _eventService.fetchAllEvents();
    });
  }

  Future<void> _handleLogout() async {
    final request = context.read<CookieRequest>();
    final authService = AuthService(request);
    await authService.logout();

    if (!mounted) return;

    try {
      ToastUtils.showSuccess(context, 'Logged out successfully');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged out successfully')),
      );
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        title: const Text("Discover Events"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _refreshEvents,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: FutureBuilder<List<Event>>(
        future: _eventsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No events found."));
          }

          final events = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async => _refreshEvents(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return EventCard(
                  event: event,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EventPublicDetailPage(event: event),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
