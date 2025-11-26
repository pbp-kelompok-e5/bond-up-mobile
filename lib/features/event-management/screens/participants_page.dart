import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart' show CookieRequest;
import '../services/event_service.dart';

class ParticipantsPage extends StatefulWidget {
  final int eventId;

  const ParticipantsPage({super.key, required this.eventId});

  @override
  State<ParticipantsPage> createState() => _ParticipantsPageState();
}

class _ParticipantsPageState extends State<ParticipantsPage> {
  late EventService service;
  late Future<List<Map<String, dynamic>>> participants;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final req = context.watch<CookieRequest>();
    service = EventService(req);
    participants = service.fetchParticipants(widget.eventId);
  }

  void reload() {
    setState(() {
      participants = service.fetchParticipants(widget.eventId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Participants"),
      ),
      body: FutureBuilder(
        future: participants,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snap.hasData || snap.data!.isEmpty) {
            return const Center(child: Text("No participants yet."));
          }

          final data = snap.data!;

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (_, i) {
              final p = data[i];

              return ListTile(
                title: Text(p["username"]),
                subtitle: Text("Status: ${p["status"]}"),
                trailing: PopupMenuButton(
                  onSelected: (value) async {
                    if (value == "remove") {
                      await service.manageParticipant(
                          widget.eventId, "remove", p["user_id"]);
                    } else if (value == "attend") {
                      await service.manageParticipant(
                          widget.eventId, "mark_attended", p["user_id"]);
                    }
                    reload();
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: "remove",
                      child: Text("Remove"),
                    ),
                    const PopupMenuItem(
                      value: "attend",
                      child: Text("Mark Attended"),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
