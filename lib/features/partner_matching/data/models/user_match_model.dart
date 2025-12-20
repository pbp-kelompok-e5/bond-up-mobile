import 'dart:convert';

// Fungsi helper buat parsing list UserMatchModel dari JSON
List<UserMatchModel> userMatchModelFromJson(String str) =>
    List<UserMatchModel>.from(json.decode(str).map((x) => UserMatchModel.fromJson(x)));

String userMatchModelToJson(List<UserMatchModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class UserMatchModel {
    int id;
    String username;
    String fullName;
    String city;
    String profilePictureUrl; 
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
    factory UserMatchModel.fromJson(Map<String, dynamic> json) {
      String parseSports(dynamic sportsData) {
        if (sportsData is List) {
          return sportsData.join(", "); // Gabungin array jadi string koma
        } else if (sportsData is String) {
          return sportsData;
        }
        return ""; // Default kosong
      }

      return UserMatchModel(
        id: json["id"],
        username: json["username"],
        fullName: json["full_name"] ?? json["username"], // Fallback ke username kalau nama kosong
        city: json["city"] ?? "",
        profilePictureUrl: json["profile_picture_url"] ?? "",
        sports: parseSports(json["sports"]),
      );
    }

    Map<String, dynamic> toJson() => {
        "id": id,
        "username": username,
        "full_name": fullName,
        "city": city,
        "profile_picture_url": profilePictureUrl,
        "sports": sports,
    };
}