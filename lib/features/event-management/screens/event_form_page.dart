// lib/features/event_management/presentation/event_form_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../services/event_service.dart';
import '../models/event.dart';

class EventFormPage extends StatefulWidget {
  final Event? event;

  const EventFormPage({super.key, this.event});

  @override
  State<EventFormPage> createState() => _EventFormPageState();
}

class _EventFormPageState extends State<EventFormPage> {
  final _formKey = GlobalKey<FormState>();

  // form fields
  String title = "";
  String description = "";
  String sportType = "";
  String thumbnail = "";
  String city = "";
  String locationName = "";
  String startTime = "";
  String endTime = "";
  DateTime? eventDate;
  int? maxParticipants;

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      final e = widget.event!;
      title = e.title;
      description = e.description;
      sportType = e.sportType;
      thumbnail = e.thumbnail;
      city = e.city;
      locationName = e.locationName;
      startTime = e.startTime;
      endTime = e.endTime;
      eventDate = e.eventDate;
      maxParticipants = e.maxParticipants;
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final service = EventService(request);
    final editing = widget.event != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(editing ? "Edit Event" : "Create Event"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _field(
                label: "Title",
                initial: title,
                onChanged: (v) => title = v,
              ),
              _field(
                label: "Description",
                initial: description,
                maxLines: 3,
                onChanged: (v) => description = v,
              ),
              _field(
                label: "Sport Type",
                initial: sportType,
                onChanged: (v) => sportType = v,
              ),
              _field(
                label: "Thumbnail URL",
                initial: thumbnail,
                onChanged: (v) => thumbnail = v,
              ),
              _field(
                label: "City",
                initial: city,
                onChanged: (v) => city = v,
              ),
              _field(
                label: "Location Name",
                initial: locationName,
                onChanged: (v) => locationName = v,
              ),
              _field(
                label: "Start Time (HH:MM:SS)",
                initial: startTime,
                onChanged: (v) => startTime = v,
              ),
              _field(
                label: "End Time (HH:MM:SS)",
                initial: endTime,
                onChanged: (v) => endTime = v,
              ),
              _field(
                label: "Max Participants",
                initial: maxParticipants?.toString() ?? "",
                keyboardType: TextInputType.number,
                onChanged: (v) => maxParticipants = int.tryParse(v),
              ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;

                  final payload = {
                    "title": title,
                    "description": description,
                    "sport_type": sportType,
                    "thumbnail": thumbnail,
                    "city": city,
                    "location_name": locationName,
                    "start_time": startTime,
                    "end_time": endTime,
                    "event_date": (eventDate ?? DateTime.now()).toIso8601String(),
                    "max_participants": maxParticipants ?? 10,
                  };

                  final res = editing
                      ? await service.updateEvent(widget.event!.id, payload)
                      : await service.createEvent(payload);

                  if (!mounted) return;

                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(res["message"] ?? "Success")));

                  Navigator.pop(context);
                },
                child: Text(editing ? "Save Changes" : "Create Event"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field({
    required String label,
    required Function(String) onChanged,
    String initial = "",
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        TextFormField(
          initialValue: initial,
          keyboardType: keyboardType,
          maxLines: maxLines,
          onChanged: onChanged,
          validator: (v) => (v == null || v.isEmpty) ? "Cannot be empty" : null,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
