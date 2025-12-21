// To parse this JSON data, do
//
//     final event = eventFromJson(jsonString);

import 'dart:convert';

List<Event> eventFromJson(String str) => List<Event>.from(json.decode(str).map((x) => Event.fromJson(x)));

String eventToJson(List<Event> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Event {
  String id;
  String organizer;
  String title;
  String description;
  String? thumbnail;
  String sportType;
  DateTime eventDate;
  String startTime;
  String endTime;
  String city;
  String locationName;
  int maxParticipants;
  int currentParticipants;
  String status;
  DateTime createdAt;
  DateTime updatedAt;

  Event({
    required this.id,
    required this.organizer,
    required this.title,
    required this.description,
    required this.thumbnail,
    required this.sportType,
    required this.eventDate,
    required this.startTime,
    required this.endTime,
    required this.city,
    required this.locationName,
    required this.maxParticipants,
    required this.currentParticipants,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Event.fromJson(Map<String, dynamic> json) => Event(
    id: json["id"].toString(),
    organizer: json["organizer"].toString(),
    title: json["title"] ?? "",
    description: json["description"] ?? "",
    thumbnail: json["thumbnail"] ?? "",
    sportType: json["sport_type"] ?? "",
    eventDate: DateTime.parse(json["event_date"]),
    startTime: json["start_time"].toString(),
    endTime: json["end_time"].toString(),
    city: json["city"] ?? "",
    locationName: json["location_name"] ?? "",
    maxParticipants: int.parse(json["max_participants"].toString()),
    currentParticipants: int.parse(json["current_participants"].toString()),
    status: json["status"] ?? "",
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "organizer": organizer,
    "title": title,
    "description": description,
    "thumbnail": thumbnail,
    "sport_type": sportType,
    "event_date": "${eventDate.year.toString().padLeft(4, '0')}-${eventDate.month.toString().padLeft(2, '0')}-${eventDate.day.toString().padLeft(2, '0')}",
    "start_time": startTime,
    "end_time": endTime,
    "city": city,
    "location_name": locationName,
    "max_participants": maxParticipants,
    "current_participants": currentParticipants,
    "status": status,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };
}
