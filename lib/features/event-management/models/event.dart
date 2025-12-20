class Event {
  Event({
    required this.id,
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
    required this.organizerUsername,
  });

  int id;
  String title;
  String description;
  String thumbnail;
  String sportType;
  DateTime eventDate;
  String startTime;
  String endTime;
  String city;
  String locationName;
  int maxParticipants;
  int currentParticipants;
  String status;
  String organizerUsername;

  factory Event.fromJson(Map<String, dynamic> json) => Event(
        id: json['id'],
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        thumbnail: json['thumbnail'] ?? '',
        sportType: json['sport_type'] ?? '',
        eventDate: DateTime.parse(json['event_date'].toString()),
        startTime: json['start_time'].toString(),
        endTime: json['end_time'].toString(),
        city: json['city'] ?? '',
        locationName: json['location_name'] ?? '',
        maxParticipants: int.parse(json['max_participants'].toString()),
        currentParticipants: int.parse(json['current_participants'].toString()),
        status: json['status'] ?? '',
        organizerUsername: json['organizer'] ?? 'Unknown',
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "thumbnail": thumbnail,
        "sport_type": sportType,
        "event_date": eventDate.toIso8601String(),
        "start_time": startTime,
        "end_time": endTime,
        "city": city,
        "location_name": locationName,
        "max_participants": maxParticipants,
        "current_participants": currentParticipants,
        "status": status,
        "organizer": organizerUsername,
      };
}
