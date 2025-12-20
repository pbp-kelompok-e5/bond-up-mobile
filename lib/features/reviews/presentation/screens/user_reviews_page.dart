import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:bond_up_mobile/core/design_system.dart';
import 'package:bond_up_mobile/features/reviews/data/models/user_review.dart';

class UserReviewsPage extends StatefulWidget {
  final int userId; // ID user yang ingin dilihat review-nya

  const UserReviewsPage({super.key, required this.userId});

  @override
  State<UserReviewsPage> createState() => _UserReviewsPageState();
}

class _UserReviewsPageState extends State<UserReviewsPage> {
  final String baseUrl = "http://localhost:8000";

  Future<List<UserReview>> fetchReviewsReceived(CookieRequest request) async {
    // Memanggil endpoint user_reviews di Django
    final response = await request.get('$baseUrl/reviews/api/user/${widget.userId}/');
    
    List<UserReview> listReview = [];
    if (response['status'] == 'success') {
      for (var d in response['data']) {
        if (d != null) {
          listReview.add(UserReview.fromJson(d));
        }
      }
    }
    return listReview;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: AppColors.deepSea,
      appBar: AppBar(
        title: const Text("User Reviews"),
        backgroundColor: AppColors.deepSea,
      ),
      body: FutureBuilder<List<UserReview>>(
        future: fetchReviewsReceived(request),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("No reviews received yet.", 
              style: TextStyle(color: Colors.white70))
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final review = snapshot.data![index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: DeepSeaCard(
                  header: Text(review.eventTitle, 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  body: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("From: ${review.reviewerName}", 
                        style: TextStyle(color: AppColors.orangeSport, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      _buildStarRating(review.rating),
                      const SizedBox(height: 8),
                      Text(review.comment, 
                        style: const TextStyle(color: Colors.white, fontSize: 14)),
                      const SizedBox(height: 8),
                      Text("Date: ${review.createdAt}", 
                        style: const TextStyle(color: Colors.white54, fontSize: 10)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStarRating(int rating) {
    return Row(
      children: List.generate(5, (i) => Icon(
        i < rating ? Icons.star : Icons.star_border,
        color: AppColors.orangeSport,
        size: 20,
      )),
    );
  }
}