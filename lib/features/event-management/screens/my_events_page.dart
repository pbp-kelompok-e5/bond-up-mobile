import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../services/event_service.dart';
import '../models/event.dart';
import 'event_form_page.dart';
import 'event_detail_page.dart';

class MyEventsPage extends StatefulWidget {
  const MyEventsPage({super.key});
  @override
  State<MyEventsPage> createState() => _MyEventsPageState();
}

class _MyEventsPageState extends State<MyEventsPage> {
  late EventService service;
  late Future<List<Event>> futureEvents;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final req = context.watch<CookieRequest>();
    service = EventService(req);
    futureEvents = service.fetchMyEvents();
  }

  void _refresh() {
    setState(() {
      final req = context.read<CookieRequest>();
      service = EventService(req);
      futureEvents = service.fetchMyEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Events'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EventFormPage()),
              );
              _refresh();
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Event>>(
        future: futureEvents,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));

          final allEvents = snap.data ?? [];
          if (allEvents.isEmpty) return const Center(child: Text('No events'));

          final today = DateTime.now();
          final upcoming = allEvents
              .where(
                (e) =>
                    e.eventDate.isAfter(today) ||
                    e.eventDate.isAtSameMomentAs(today),
              )
              .toList();
          final past = allEvents
              .where((e) => e.eventDate.isBefore(today))
              .toList();

          return ListView(
            padding: const EdgeInsets.all(8),
            children: [
              _buildSection("Upcoming Events", upcoming),
              const SizedBox(height: 20),
              _buildSection("Past Events", past, isPast: true),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection(
    String title,
    List<Event> events, {
    bool isPast = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        if (events.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: Text("No events in this category.")),
          ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: events.length,
          itemBuilder: (context, idx) {
            final e = events[idx];
            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: ListTile(
                title: Text(e.title),
                subtitle: Text(
                  '${e.city} • ${e.eventDate.toLocal().toString().substring(0, 10)}',
                ),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EventDetailPage(event: e),
                    ),
                  );
                  _refresh();
                },
                trailing: _buildPopupMenu(e, isPast),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPopupMenu(Event event, bool isPast) {
    return PopupMenuButton<String>(
      onSelected: (value) async {
        if (value == 'edit') {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => EventFormPage(event: event)),
          );
          _refresh();
        } else if (value == 'delete') {
          final confirm = await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text("Confirm Deletion"),
              content: const Text(
                "Are you sure you want to delete this event?",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text("Delete"),
                ),
              ],
            ),
          );

          if (confirm ?? false) {
            final res = await service.deleteEvent(event.id);
            if (!mounted) return;
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(res["message"])));
            _refresh();
          }
        } else if (value == 'cancel') {
          final confirm = await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text("Confirm Cancellation"),
              content: const Text(
                "Are you sure you want to cancel this event?",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text("No"),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text("Yes"),
                ),
              ],
            ),
          );

          if (confirm ?? false) {
            final res = await service.cancelEvent(event.id);
            if (!mounted) return;
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(res["message"])));
            _refresh();
          }
        }
      },
      itemBuilder: (context) => [
        if (!isPast) const PopupMenuItem(value: 'edit', child: Text('Edit')),
        if (!isPast && event.status == "upcoming")
          const PopupMenuItem(value: 'cancel', child: Text('Cancel')),
        const PopupMenuItem(value: 'delete', child: Text('Delete')),
      ],
    );
  }
}
