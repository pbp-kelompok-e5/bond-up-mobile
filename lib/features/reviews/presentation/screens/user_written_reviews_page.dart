import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:bond_up_mobile/core/design_system.dart'; 
import 'package:bond_up_mobile/features/reviews/data/models/user_written_review.dart';

class UserWrittenReviewsPage extends StatefulWidget {
  const UserWrittenReviewsPage({super.key});

  @override
  State<UserWrittenReviewsPage> createState() => _UserWrittenReviewsPageState();
}

class _UserWrittenReviewsPageState extends State<UserWrittenReviewsPage> {
  final String baseUrl = "http://localhost:8000";

  // 1. Fetch Data
  Future<List<UserWrittenReview>> fetchMyWrittenReviews(CookieRequest request) async {
    final response = await request.get('$baseUrl/reviews/api/my-reviews/');
    
    List<UserWrittenReview> listReview = [];
    if (response['status'] == 'success') {
      for (var d in response['data']) {
        if (d != null) {
          listReview.add(UserWrittenReview.fromJson(d));
        }
      }
    }
    return listReview;
  }

  // 2. Delete Data
  Future<void> deleteMyReview(CookieRequest request, int id) async {
    final response = await request.post('$baseUrl/reviews/ajax/delete/$id/', {});
    if (response['ok']) {
      setState(() {}); 
      if (mounted) ToastUtils.showSuccess(context, "Review deleted!");
    }
  }

  // 3. Update Data (Fitur Edit)
  Future<void> updateMyReview(CookieRequest request, int id, int rating, String comment) async {
    final response = await request.post(
      '$baseUrl/reviews/ajax/update/$id/',
      {
        'rating': rating.toString(),
        'comment': comment,
      },
    );

    if (response['ok']) {
      setState(() {}); 
      if (mounted) ToastUtils.showSuccess(context, "Review updated!");
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: AppColors.deepSea,
      appBar: AppBar(title: const Text("My Written Reviews")),
      body: FutureBuilder<List<UserWrittenReview>>(
        future: fetchMyWrittenReviews(request),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("You haven't written any reviews.", style: TextStyle(color: Colors.white)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final review = snapshot.data![index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: DeepSeaCard(
                  header: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(review.eventTitle, style: const TextStyle(fontWeight: FontWeight.bold))),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blueAccent, size: 20),
                            onPressed: () => _showEditDialog(request, review),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                            onPressed: () => _confirmDelete(request, review.id),
                          ),
                        ],
                      ),
                    ],
                  ),
                  body: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Reviewed: ${review.revieweeName}", style: TextStyle(color: AppColors.orangeSport)),
                      const SizedBox(height: 4),
                      _buildStarRating(review.rating),
                      const SizedBox(height: 8),
                      Text(review.comment, style: const TextStyle(color: Colors.white70)),
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

  // --- Helpers: Dialogs & Widgets ---

  void _showEditDialog(CookieRequest request, UserWrittenReview review) {
    int tempRating = review.rating;
    TextEditingController commentController = TextEditingController(text: review.comment);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          backgroundColor: AppColors.deepSeaLight,
          title: const Text("Edit Review", style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) => IconButton(
                  icon: Icon(
                    i < tempRating ? Icons.star : Icons.star_border,
                    color: AppColors.orangeSport,
                  ),
                  onPressed: () => setStateDialog(() => tempRating = i + 1),
                )),
              ),
              AppTextField(controller: commentController, hint: "Edit comment..."),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            AppButton(
              text: "Save",
              onPressed: () {
                Navigator.pop(context);
                updateMyReview(request, review.id, tempRating, commentController.text);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(CookieRequest request, int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Review?"),
        content: const Text("Are you sure you want to delete this review?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () { Navigator.pop(context); deleteMyReview(request, id); },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildStarRating(int rating) {
    return Row(
      children: List.generate(5, (i) => Icon(
        i < rating ? Icons.star : Icons.star_border,
        color: AppColors.orangeSport, size: 18,
      )),
    );
  }
}