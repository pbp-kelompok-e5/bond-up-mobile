import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../services/event_service.dart';
import '../models/event.dart';
import 'event_form_page.dart';
import 'participants_page.dart';
// import 'event_detail_page.dart';

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
              await Navigator.push(context, MaterialPageRoute(builder: (_) => const EventFormPage()));
              _refresh();
            },
          )
        ],
      ),
      body: FutureBuilder<List<Event>>(
        future: futureEvents,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
          if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
          final events = snap.data ?? [];
          if (events.isEmpty) return const Center(child: Text('No events'));
          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, idx) {
              final e = events[idx];
              return ListTile(
                title: Text(e.title),
                subtitle: Text('${e.city} • ${e.eventDate.toLocal().toIso8601String().split("T").first}'),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ParticipantsPage(eventId: e.id))),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    await Navigator.push(context, MaterialPageRoute(builder: (_) => EventFormPage(event: e)));
                    _refresh();
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
