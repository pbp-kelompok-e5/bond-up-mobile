import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../../event-management/models/event.dart';

const String baseApi = "http://localhost:8000/event-discovery";

class EventDiscoveryService {
  final CookieRequest request;
  EventDiscoveryService(this.request);

  Future<List<Event>> fetchAllEvents() async {
    final res = await request.get("$baseApi/events/json/");
    List data = res;
    return data.map((e) => Event.fromJson(e)).toList();
  }
}
