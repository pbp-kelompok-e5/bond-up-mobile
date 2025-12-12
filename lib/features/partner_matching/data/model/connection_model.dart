import 'user_match_model.dart';

class Connection {
  final List<UserMatchModel> myFriends;
  final List<UserMatchModel> receivedRequests;
  final List<UserMatchModel> sentRequests;
  final List<UserMatchModel> recommendations;

  Connection({
    required this.myFriends,
    required this.receivedRequests,
    required this.sentRequests,
    required this.recommendations,
  });

  factory Connection.fromJson(Map<String, dynamic> json) {
    // Helper function untuk parse list UserMatchModel
    List<UserMatchModel> parseList(String key) {
      if (json[key] != null) {
        return List<UserMatchModel>.from(
            json[key].map((x) => UserMatchModel.fromJson(x)));
      }
      return [];
    }

    return Connection (
      myFriends: parseList('my_friends'),
      receivedRequests: parseList('received_requests'),
      sentRequests: parseList('sent_requests'),
      recommendations: parseList('recommendations'),
    );
  }
}