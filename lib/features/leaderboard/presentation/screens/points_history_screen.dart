import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:bond_up_mobile/core/design_system.dart';
import 'package:bond_up_mobile/features/leaderboard/data/services/leaderboard_service.dart';
import 'package:bond_up_mobile/features/leaderboard/data/models/points_history_model.dart';
import 'package:intl/intl.dart';

/// Points history screen showing user's points transaction history
class PointsHistoryScreen extends StatefulWidget {
  const PointsHistoryScreen({super.key});

  @override
  State<PointsHistoryScreen> createState() => _PointsHistoryScreenState();
}

class _PointsHistoryScreenState extends State<PointsHistoryScreen> {
  List<PointsTransactionModel> _transactions = [];
  bool _isLoading = true;
  int _totalTransactions = 0;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
    });

    final request = context.read<CookieRequest>();
    final leaderboardService = LeaderboardService(request);

    final response = await leaderboardService.getPointsHistory(limit: 100);

    if (mounted) {
      setState(() {
        _transactions = response.transactions;
        _totalTransactions = response.totalTransactions;
        _isLoading = false;
      });

      if (!response.status) {
        ToastUtils.showError(context, response.message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepSea,
      appBar: AppBar(
        title: const Text(
          'Points History',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.deepSeaLight,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: _loadHistory,
        color: AppColors.orangeSport,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.orangeSport,
                ),
              )
            : _buildHistoryList(),
      ),
    );
  }

  Widget _buildHistoryList() {
    if (_transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.history,
              size: 80,
              color: Colors.white54,
            ),
            const SizedBox(height: 16),
            const Text(
              'No points history yet',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Start participating in events to earn points!',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _transactions.length + 1, // +1 for header
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildHeader();
        }

        final transaction = _transactions[index - 1];
        return _buildTransactionCard(transaction);
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: DeepSeaCard(
        body: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Transaction History',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.orangeSport.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$_totalTransactions total',
                style: const TextStyle(
                  color: AppColors.orangeSport,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCard(PointsTransactionModel transaction) {
    final dateFormat = DateFormat('MMM dd, yyyy • HH:mm');
    final isPositive = transaction.points >= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: DeepSeaCard(
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Activity icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isPositive
                    ? AppColors.orangeSport.withValues(alpha: 0.2)
                    : Colors.red.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getActivityIcon(transaction.activityType),
                color: isPositive ? AppColors.orangeSport : Colors.red,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            // Transaction details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.activityLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    transaction.description,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    dateFormat.format(transaction.createdAt),
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // Points
            Text(
              '${isPositive ? '+' : ''}${transaction.points}',
              style: TextStyle(
                color: isPositive ? AppColors.orangeSport : Colors.red,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getActivityIcon(String activityType) {
    switch (activityType) {
      case 'event_join':
        return Icons.event_available;
      case 'event_complete':
        return Icons.check_circle;
      case 'event_organize':
        return Icons.event;
      case 'review_given':
        return Icons.rate_review;
      case 'five_star_received':
        return Icons.star;
      default:
        return Icons.emoji_events;
    }
  }
}
