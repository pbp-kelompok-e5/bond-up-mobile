// To parse this JSON data, do
//
//     final connection = connectionFromJson(jsonString);

import 'dart:convert';

Connection connectionFromJson(String str) => Connection.fromJson(json.decode(str));

String connectionToJson(Connection data) => json.encode(data.toJson());

class Connection {
    String status;
    List<MyFriend> myFriends;
    List<dynamic> receivedRequests;
    List<MyFriend> sentRequests;
    List<Recommendation> recommendations;

    Connection({
        required this.status,
        required this.myFriends,
        required this.receivedRequests,
        required this.sentRequests,
        required this.recommendations,
    });

    factory Connection.fromJson(Map<String, dynamic> json) => Connection(
        status: json["status"],
        myFriends: List<MyFriend>.from(json["my_friends"].map((x) => MyFriend.fromJson(x))),
        receivedRequests: List<dynamic>.from(json["received_requests"].map((x) => x)),
        sentRequests: List<MyFriend>.from(json["sent_requests"].map((x) => MyFriend.fromJson(x))),
        recommendations: List<Recommendation>.from(json["recommendations"].map((x) => Recommendation.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "my_friends": List<dynamic>.from(myFriends.map((x) => x.toJson())),
        "received_requests": List<dynamic>.from(receivedRequests.map((x) => x)),
        "sent_requests": List<dynamic>.from(sentRequests.map((x) => x.toJson())),
        "recommendations": List<dynamic>.from(recommendations.map((x) => x.toJson())),
    };
}

class MyFriend {
    int id;
    String username;
    String fullName;
    String city;
    String profilePictureUrl;
    List<Sport> sports;

    MyFriend({
        required this.id,
        required this.username,
        required this.fullName,
        required this.city,
        required this.profilePictureUrl,
        required this.sports,
    });

    factory MyFriend.fromJson(Map<String, dynamic> json) => MyFriend(
        id: json["id"],
        username: json["username"],
        fullName: json["full_name"],
        city: json["city"],
        profilePictureUrl: json["profile_picture_url"],
        sports: List<Sport>.from(json["sports"].map((x) => sportValues.map[x]!)),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "username": username,
        "full_name": fullName,
        "city": city,
        "profile_picture_url": profilePictureUrl,
        "sports": List<dynamic>.from(sports.map((x) => sportValues.reverse[x])),
    };
}

enum Sport {
    BADMINTON,
    BASKETBALL,
    CYCLING,
    FOOTBALL,
    RUNNING,
    SWIMMING,
    TENNIS,
    VOLLEYBALL
}

final sportValues = EnumValues({
    "badminton": Sport.BADMINTON,
    "basketball": Sport.BASKETBALL,
    "cycling": Sport.CYCLING,
    "football": Sport.FOOTBALL,
    "running": Sport.RUNNING,
    "swimming": Sport.SWIMMING,
    "tennis": Sport.TENNIS,
    "volleyball": Sport.VOLLEYBALL
});

class Recommendation {
    int id;
    String username;
    String fullName;
    String city;
    String profilePictureUrl;
    List<Sport> sports;
    int score;
    List<Sport> commonSports;
    bool sameCity;

    Recommendation({
        required this.id,
        required this.username,
        required this.fullName,
        required this.city,
        required this.profilePictureUrl,
        required this.sports,
        required this.score,
        required this.commonSports,
        required this.sameCity,
    });

    factory Recommendation.fromJson(Map<String, dynamic> json) => Recommendation(
        id: json["id"],
        username: json["username"],
        fullName: json["full_name"],
        city: json["city"],
        profilePictureUrl: json["profile_picture_url"],
        sports: List<Sport>.from(json["sports"].map((x) => sportValues.map[x]!)),
        score: json["score"],
        commonSports: List<Sport>.from(json["common_sports"].map((x) => sportValues.map[x]!)),
        sameCity: json["same_city"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "username": username,
        "full_name": fullName,
        "city": city,
        "profile_picture_url": profilePictureUrl,
        "sports": List<dynamic>.from(sports.map((x) => sportValues.reverse[x])),
        "score": score,
        "common_sports": List<dynamic>.from(commonSports.map((x) => sportValues.reverse[x])),
        "same_city": sameCity,
    };
}

class EnumValues<T> {
    Map<String, T> map;
    late Map<T, String> reverseMap;

    EnumValues(this.map);

    Map<T, String> get reverse {
            reverseMap = map.map((k, v) => MapEntry(v, k));
            return reverseMap;
    }
}
