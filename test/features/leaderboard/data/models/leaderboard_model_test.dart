import 'package:flutter_test/flutter_test.dart';
// Ganti import ini sesuai lokasi file model kamu sebenarnya
import 'package:bond_up_mobile/features/leaderboard/data/models/leaderboard_entry_model.dart'; 

void main() {
  // Data JSON dummy yang valid untuk digunakan berulang
  final tEntryJson = {
    'rank': 1,
    'user_id': 101,
    'username': 'johndoe',
    'full_name': 'John Doe',
    'profile_image_url': 'https://example.com/image.jpg',
    'total_points': 500,
    'total_events': 10,
    'tier': 'Gold',
    'badge': 'Champion',
  };

  final tEntryModel = LeaderboardEntryModel(
    rank: 1,
    userId: 101,
    username: 'johndoe',
    fullName: 'John Doe',
    profileImageUrl: 'https://example.com/image.jpg',
    totalPoints: 500,
    totalEvents: 10,
    tier: 'Gold',
    badge: 'Champion',
  );

  group('LeaderboardEntryModel', () {
    group('fromJson', () {
      test('should return a valid model when JSON is complete', () {
        // Act
        final result = LeaderboardEntryModel.fromJson(tEntryJson);

        // Assert
        expect(result.rank, 1);
        expect(result.username, 'johndoe');
        expect(result.profileImageUrl, 'https://example.com/image.jpg');
      });

      test('should return empty string for profileImageUrl when it is null', () {
        // Arrange
        // Kita copy map agar tidak mengubah tEntryJson asli
        final jsonWithNullImage = Map<String, dynamic>.from(tEntryJson);
        jsonWithNullImage['profile_image_url'] = null;

        // Act
        final result = LeaderboardEntryModel.fromJson(jsonWithNullImage);

        // Assert
        // Ini mengetes baris: json['profile_image_url'] as String? ?? ''
        expect(result.profileImageUrl, '');
        expect(result.username, 'johndoe');
      });

       test('should return empty string for profileImageUrl when key is missing', () {
        // Arrange
        final jsonMissingImageKey = Map<String, dynamic>.from(tEntryJson);
        jsonMissingImageKey.remove('profile_image_url');

        // Act
        final result = LeaderboardEntryModel.fromJson(jsonMissingImageKey);

        // Assert
        expect(result.profileImageUrl, '');
      });
    });

    group('toJson', () {
      test('should return a JSON map containing proper data', () {
        // Act
        final result = tEntryModel.toJson();

        // Assert
        expect(result, tEntryJson);
      });
    });
  });

  group('LeaderboardResponseModel', () {
    final tResponseJson = {
      'status': true,
      'message': 'Success',
      'data': {
        'users': [tEntryJson],
        'current_user_rank': 5,
        'total_users': 100,
        'current_page': 1,
        'total_pages': 10,
        'has_next': true,
        'has_previous': false,
      }
    };

    group('fromJson', () {
      test('should return valid model from complete JSON', () {
        // Act
        final result = LeaderboardResponseModel.fromJson(tResponseJson);

        // Assert
        expect(result.status, true);
        expect(result.message, 'Success');
        expect(result.users.length, 1);
        expect(result.users.first.username, 'johndoe');
        expect(result.currentUserRank, 5);
        expect(result.totalUsers, 100);
        expect(result.hasNext, true);
      });

      test('should handle null/missing fields with default values (Coverage for ?? operators)', () {
        // Arrange
        // JSON kosong untuk memicu semua fallback value (??)
        final emptyJson = <String, dynamic>{};

        // Act
        final result = LeaderboardResponseModel.fromJson(emptyJson);

        // Assert
        // Menguji: status: json['status'] as bool? ?? false
        expect(result.status, false);
        
        // Menguji: message: json['message'] as String? ?? ''
        expect(result.message, '');
        
        // Menguji: usersList = data['users']... ?? []
        expect(result.users, isEmpty);
        
        // Menguji: totalUsers: data['total_users']... ?? 0
        expect(result.totalUsers, 0);
        
        // Menguji: currentPage: ... ?? 1
        expect(result.currentPage, 1);
        
        // Menguji: totalPages: ... ?? 1
        expect(result.totalPages, 1);
        
        // Menguji: hasNext: ... ?? false
        expect(result.hasNext, false);
        
        // Menguji: hasPrevious: ... ?? false
        expect(result.hasPrevious, false);
        
        // Menguji: currentUserRank (nullable, tidak ada default)
        expect(result.currentUserRank, isNull);
      });

      test('should handle when data key exists but is null', () {
        // Arrange
        final jsonWithNullData = {'data': null, 'status': true};

        // Act
        final result = LeaderboardResponseModel.fromJson(jsonWithNullData);

        // Assert
        // Menguji: final data = json['data'] as Map<String, dynamic>? ?? {};
        expect(result.users, isEmpty);
        expect(result.totalUsers, 0);
        expect(result.status, true); // Status tetap diambil dari root
      });

      test('should handle when users list inside data is null', () {
        // Arrange
        final jsonWithNullUsers = {
          'data': {
            'users': null,
            'total_users': 50
          }
        };

        // Act
        final result = LeaderboardResponseModel.fromJson(jsonWithNullUsers);

        // Assert
        // Menguji: final usersList = data['users'] as List<dynamic>? ?? [];
        expect(result.users, isEmpty);
        expect(result.totalUsers, 50);
      });
    });
    
    // Note: LeaderboardResponseModel tidak memiliki method toJson dalam kode yang diberikan,
    // jadi tidak ada tes untuk toJson di sini.
  });
}