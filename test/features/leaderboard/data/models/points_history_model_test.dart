import 'package:flutter_test/flutter_test.dart';
import 'package:bond_up_mobile/features/leaderboard/data/models/points_history_model.dart'; 

void main() {
  // --- Data Dummy ---
  final tDateStr = '2025-01-15T14:30:00.000';
  final tDate = DateTime.parse(tDateStr);

  final tTransactionJson = {
    'id': 101,
    'activity_type': 'event_join',
    'activity_label': 'Joined Flutter Workshop',
    'points': 50,
    'description': 'Bonus points for early bird',
    'created_at': tDateStr,
  };

  final tTransactionModel = PointsTransactionModel(
    id: 101,
    activityType: 'event_join',
    activityLabel: 'Joined Flutter Workshop',
    points: 50,
    description: 'Bonus points for early bird',
    createdAt: tDate,
  );

  // --- Tests untuk PointsTransactionModel ---
  group('PointsTransactionModel', () {
    test('fromJson should return a valid model from JSON', () {
      // Act
      final result = PointsTransactionModel.fromJson(tTransactionJson);

      // Assert
      expect(result.id, 101);
      expect(result.activityType, 'event_join');
      expect(result.points, 50);
      expect(result.createdAt, tDate);
    });

    test('toJson should return a JSON map containing proper data', () {
      // Act
      final result = tTransactionModel.toJson();

      // Assert
      expect(result['id'], 101);
      expect(result['activity_type'], 'event_join');
      expect(result['created_at'], tDateStr); // Memastikan format ISO string
    });
  });

  // --- Tests untuk PointsHistoryResponseModel ---
  group('PointsHistoryResponseModel', () {
    test('fromJson should return valid model when JSON is complete', () {
      // Arrange
      final tResponseJson = {
        'status': true,
        'message': 'Data retrieved',
        'data': {
          'transactions': [tTransactionJson],
          'total_transactions': 15,
        }
      };

      // Act
      final result = PointsHistoryResponseModel.fromJson(tResponseJson);

      // Assert
      expect(result.status, true);
      expect(result.message, 'Data retrieved');
      expect(result.transactions.length, 1);
      expect(result.transactions.first.id, 101);
      expect(result.totalTransactions, 15);
    });

    test('fromJson should handle missing fields with default values (Coverage for ?? operators)', () {
      // Arrange
      // JSON kosong untuk memicu semua fallback value (??)
      final emptyJson = <String, dynamic>{};

      // Act
      final result = PointsHistoryResponseModel.fromJson(emptyJson);

      // Assert
      // Menguji: status: json['status'] as bool? ?? false
      expect(result.status, false);

      // Menguji: message: json['message'] as String? ?? ''
      expect(result.message, '');

      // Menguji: final data = json['data'] ... ?? {} -> transactionsList default []
      expect(result.transactions, isEmpty);

      // Menguji: totalTransactions: data['total_transactions'] ... ?? 0
      expect(result.totalTransactions, 0);
    });

    test('fromJson should handle "data" key being null', () {
      // Arrange
      final jsonWithNullData = {
        'status': true,
        'data': null,
      };

      // Act
      final result = PointsHistoryResponseModel.fromJson(jsonWithNullData);

      // Assert
      // Memastikan logika: final data = json['data'] as Map<String, dynamic>? ?? {};
      expect(result.transactions, isEmpty);
      expect(result.totalTransactions, 0);
    });

    test('fromJson should handle "transactions" list being null inside data', () {
      // Arrange
      final jsonWithNullList = {
        'data': {
          'transactions': null,
          'total_transactions': 5
        }
      };

      // Act
      final result = PointsHistoryResponseModel.fromJson(jsonWithNullList);

      // Assert
      // Memastikan logika: final transactionsList = data['transactions'] ... ?? [];
      expect(result.transactions, isEmpty);
      // Memastikan field lain di dalam data tetap terbaca
      expect(result.totalTransactions, 5);
    });
    
    // Note: PointsHistoryResponseModel tidak memiliki method toJson dalam kode yang diberikan,
    // jadi tidak ada tes untuk toJson di sini.
  });
}