import 'package:bond_up_mobile/features/partner_matching/data/model/user_match_model.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
// import 'package:bond-up/core/constants.dart'; // Pastikan BASE_URL ada di sini
import '../model/user_match_model.dart';
import '../model/connection_model.dart';
import '../model/profile_detail_model.dart';

class PartnerMatchingRemoteDataSource {
  // Ganti http.Client jadi CookieRequest
  final CookieRequest request;
  final String baseUrl = "http://localhost:8000";

  PartnerMatchingRemoteDataSource(this.request);

  // 1. Fetch Users (Browse)
  Future<List<UserMatchModel>> fetchUsers({
    String query = '',
    String sport = '',
    String skill = '',
    String city = '',
  }) async {
    // Bangun query parameters
    final queryParams = {
      'search': query,
      'sport': sport,
      'skill': skill,
      'city': city,
    };

    // Bikin URL lengkap dengan parameter
    // pbp_django_auth butuh String URL, bukan Uri object
    final String url = Uri.parse('$baseUrl/partner-matching/browse-users-api/')
        .replace(queryParameters: queryParams)
        .toString();

    try {
      // PENTING: request.get() langsung mengembalikan JSON (dynamic)
      final response = await request.get(url);

      // Cek apakah response valid (biasanya Map)
      if (response != null) {
        // Langsung akses key 'users' tanpa json.decode
        List<dynamic> usersJson = response['users'];
        
        return usersJson.map((json) => UserMatchModel.fromJson(json)).toList();
      } else {
        throw Exception('Response kosong dari server');
      }
    } catch (e) {
      throw Exception('Error fetching users: $e');
    }
  }

  // 2. Fetch Connections (My Connections)
  Future<Connection> fetchConnections() async {
    final String url = '$baseUrl/partner-matching/connections/api/';

    try {
      final response = await request.get(url);

      // Langsung cek isi JSON
      if (response['status'] == 'success') {
        return Connection.fromJson(response);
      } else {
        throw Exception('Server error: ${response['message']}');
      }
    } catch (e) {
      throw Exception('Error fetching connections: $e');
    }
  }

  // 3. Connection Actions (Connect, Accept, Reject, Remove, Cancel)
  Future<bool> sendConnectionAction(String action, int userId) async {
    final String url = '$baseUrl/partner-matching/connection/$action/user/$userId/';

    try {
      // request.post() butuh body berupa Map (JSON)
      // Meskipun body kosong, tetap kirim Map kosong {}
      final response = await request.post(url, {});

      // Langsung cek field 'success' dari response JSON
      if (response['success'] == true) {
        return true;
      } else {
        print("Action failed: ${response['error']}");
        return false;
      }
    } catch (e) {
      print("Error sending action: $e");
      return false;
    }
  }

  // partner_matching_remote_datasource.dart
  Future<Map<String, List<Map<String, String>>>> fetchFilterOptions() async {
    final String url = '$baseUrl/partner-matching/filter-options-api/';

    try {
      final response = await request.get(url);
      
      // Response udah otomatis di-decode jadi Map/List sama pbp_django_auth
      // Kita casting biar aman
      return {
        'cities': List<Map<String, String>>.from(
            response['cities'].map((x) => {'value': x['value'].toString(), 'label': x['label'].toString()})
        ),
        'sports': List<Map<String, String>>.from(
            response['sports'].map((x) => {'value': x['value'].toString(), 'label': x['label'].toString()})
        ),
        'skills': List<Map<String, String>>.from(
            response['skills'].map((x) => {'value': x['value'].toString(), 'label': x['label'].toString()})
        ),
      };
    } catch (e) {
      throw Exception('Error fetching filters: $e');
    }
  }

  Future<ProfileDetailModel> fetchUserProfile(int userId) async {
    final String url = '$baseUrl/partner-matching/profile/$userId/api/';

    try {
      final response = await request.get(url);

      if (response['status'] == true) {
        return ProfileDetailModel.fromJson(response);
      } else {
        throw Exception('Gagal load profil');
      }
    } catch (e) {
      throw Exception('Error fetching profile: $e');
    }
  }
}