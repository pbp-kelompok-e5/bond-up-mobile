/// Model for a single points transaction
class PointsTransactionModel {
  final int id;
  final String activityType;
  final String activityLabel;
  final int points;
  final String description;
  final DateTime createdAt;

  PointsTransactionModel({
    required this.id,
    required this.activityType,
    required this.activityLabel,
    required this.points,
    required this.description,
    required this.createdAt,
  });

  /// Create PointsTransactionModel from JSON
  factory PointsTransactionModel.fromJson(Map<String, dynamic> json) {
    return PointsTransactionModel(
      id: int.parse(json['id'].toString()),
      activityType: json['activity_type']?.toString() ?? '',
      activityLabel: json['activity_label']?.toString() ?? '',
      points: int.parse(json['points'].toString()),
      description: json['description']?.toString() ?? '',
      createdAt: DateTime.parse(json['created_at'].toString()),
    );
  }

  /// Convert PointsTransactionModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'activity_type': activityType,
      'activity_label': activityLabel,
      'points': points,
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

/// Model for points history response
class PointsHistoryResponseModel {
  final bool status;
  final String message;
  final List<PointsTransactionModel> transactions;
  final int totalTransactions;

  PointsHistoryResponseModel({
    required this.status,
    required this.message,
    required this.transactions,
    required this.totalTransactions,
  });

  /// Create PointsHistoryResponseModel from JSON
  factory PointsHistoryResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final transactionsList = data['transactions'] as List<dynamic>? ?? [];

    return PointsHistoryResponseModel(
      status: json['status'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      transactions: transactionsList
          .map((transaction) => PointsTransactionModel.fromJson(transaction as Map<String, dynamic>))
          .toList(),
      totalTransactions: data['total_transactions'] as int? ?? 0,
    );
  }
}

