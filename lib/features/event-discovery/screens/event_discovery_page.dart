import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:bond_up_mobile/features/event-discovery/data/models/event_model.dart';
import 'package:bond_up_mobile/features/event-discovery/data/services/event_discovery_service.dart';
import 'package:bond_up_mobile/features/event-discovery/widget/disc_event_filterbar.dart';
import 'package:bond_up_mobile/features/event-discovery/screens/event_detail.page.dart';
import 'package:bond_up_mobile/core/widgets/navigation/app_drawer.dart';

class EventDiscoveryScreen extends StatefulWidget{
  const EventDiscoveryScreen({super.key});

  @override
  State<EventDiscoveryScreen> createState() => _EventDiscoveryScreenState();
}

class _EventDiscoveryScreenState extends State<EventDiscoveryScreen>{
  // List of All Events
  late Future<List<Event>> _futureEvents;

  Future<List<Event>> fetchEvents(BuildContext context) async {
    final request = context.watch<CookieRequest>();
    final service = EventDiscoveryService(request);

    return service.fetchEvents(request);
  }

  @override
  Widget build(BuildContext context) {

  }

}