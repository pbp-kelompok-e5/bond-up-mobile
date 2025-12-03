import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../models/event.dart';
import 'participants_page.dart';
import 'event_form_page.dart';
import '../services/event_service.dart';

class EventDetailPage extends StatelessWidget {
  final Event event;

  const EventDetailPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final service = EventService(request);

    return Scaffold(
      appBar: AppBar(
        title: Text(event.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EventFormPage(event: event)),
              );
            },
          ),
          if (event.status == "upcoming")
            IconButton(
              icon: const Icon(Icons.cancel),
              onPressed: () async {
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
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(res["message"])));
                  Navigator.pop(context);
                }
              },
            ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final res = await service.deleteEvent(event.id);
              if (!context.mounted) return;
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(res["message"])));
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Image.network(
            event.thumbnail,
            height: 200,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              height: 200,
              color: Colors.grey,
              child: const Icon(Icons.broken_image),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            event.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(event.description),
          const SizedBox(height: 12),
          Text("Sport: ${event.sportType}"),
          Text("City: ${event.city}"),
          Text("Location: ${event.locationName}"),
          Text(
            "Date: ${event.eventDate.toLocal().toString().substring(0, 10)}",
          ),
          Text("Time: ${event.startTime} - ${event.endTime}"),
          Text(
            "Participants: ${event.currentParticipants}/${event.maxParticipants}",
          ),
          Text(
            "Status: ${event.status}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 30),

          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ParticipantsPage(eventId: event.id),
              ),
            ),
            child: const Text("Manage Participants"),
          ),
        ],
      ),
    );
  }
}
