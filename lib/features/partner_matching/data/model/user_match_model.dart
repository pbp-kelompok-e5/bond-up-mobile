// lib/features/partner_matching/data/models/user_match_model.dart

import 'dart:convert';

// Fungsi helper buat parsing list (Opsional, tapi ngebantu)
List<UserMatchModel> userMatchModelFromJson(String str) =>
    List<UserMatchModel>.from(json.decode(str).map((x) => UserMatchModel.fromJson(x)));

String userMatchModelToJson(List<UserMatchModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class UserMatchModel {
    int id;
    String username;
    String fullName;
    String city;
    String profilePictureUrl; // Udah bener camelCase
    String sports;

    UserMatchModel({
        required this.id,
        required this.username,
        required this.fullName,
        required this.city,
        required this.profilePictureUrl,
        required this.sports,
    });

    // Factory method ini yang dipake di Datasource nanti
    factory UserMatchModel.fromJson(Map<String, dynamic> json) => UserMatchModel(
        id: json["id"],
        username: json["username"],
        fullName: json["full_name"], // Mapping dari snake_case (Django)
        city: json["city"],
        profilePictureUrl: json["profile_picture_url"], // ke camelCase (Flutter)
        sports: json["sports"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "username": username,
        "full_name": fullName,
        "city": city,
        "profile_picture_url": profilePictureUrl,
        "sports": sports,
    };
}