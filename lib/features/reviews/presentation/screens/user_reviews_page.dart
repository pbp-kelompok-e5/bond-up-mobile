import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:bond_up_mobile/core/design_system.dart';
import 'package:bond_up_mobile/features/reviews/data/models/user_review.dart';
import 'package:bond_up_mobile/core/constants/api_constants.dart';
import 'package:bond_up_mobile/core/theme/app_colors.dart'; // Pastiin path-nya bener ya

class UserReviewsPage extends StatefulWidget {
  final int userId; // ID user yang mau kita kepoin review-nya

  const UserReviewsPage({super.key, required this.userId});

  @override
  State<UserReviewsPage> createState() => _UserReviewsPageState();
}

class _UserReviewsPageState extends State<UserReviewsPage> {
  
  // Fungsi buat ngambil data review dari backend Django
  Future<List<UserReview>> fetchReviewsReceived(CookieRequest request) async {
    try {
      final response = await request.get('${ApiConstants.baseUrl}/reviews/api/user/${widget.userId}/');
      
      List<UserReview> listReview = [];
      if (response['status'] == 'success') {
        for (var d in response['data']) {
          if (d != null) {
            listReview.add(UserReview.fromJson(d));
          }
        }
      }
      return listReview;
    } catch (e) {
      // Kalo error (misal koneksi putus), balikin list kosong dulu atau bisa throw error
      // print("Error fetching reviews: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: AppColors.deepSea, // Background utama gelap biar elegan
      appBar: AppBar(
        title: const Text(
          "User Reviews", 
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.white)
        ),
        backgroundColor: AppColors.deepSea,
        elevation: 0, //ilangin bayangan di appbar biar nyatu sama body
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      body: FutureBuilder<List<UserReview>>(
        future: fetchReviewsReceived(request),
        builder: (context, snapshot) {
          // 1. Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.orangeSport)
            );
          }
          
          // 2. Error State
          if (snapshot.hasError) {
             return Center(
              child: Text("Gagal memuat data.", style: TextStyle(color: AppColors.gray400))
            );
          }

          // 3. Empty State (Kalo belum ada review)
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.rate_review_outlined, size: 80, color: AppColors.deepSeaLighter),
                  const SizedBox(height: 16),
                  const Text(
                    "Belum ada review nih.", 
                    style: TextStyle(color: Colors.white70, fontSize: 16)
                  ),
                ],
              )
            );
          }

          // 4. Data Ada -> Tampilkan List
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            itemCount: snapshot.data!.length,
            separatorBuilder: (ctx, index) => const SizedBox(height: 16), // Jarak antar kartu
            itemBuilder: (context, index) {
              final review = snapshot.data![index];
              return _buildReviewCard(review);
            },
          );
        },
      ),
    );
  }

  // Widget kartu review dipisah biar kode utama lebih bersih
  Widget _buildReviewCard(UserReview review) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.deepSeaLight, // Warna kartu sedikit lebih terang
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.deepSeaLighter, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Avatar, Nama Reviewer, dan Tanggal
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bikin avatar inisial nama biar keren
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.orangeSport,
                child: Text(
                  review.reviewerName.isNotEmpty ? review.reviewerName[0].toUpperCase() : "?",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.reviewerName, 
                      style: const TextStyle(
                        color: AppColors.white, 
                        fontWeight: FontWeight.bold,
                        fontSize: 14
                      ),
                    ),
                    Text(
                      review.eventTitle, 
                      style: const TextStyle(
                        color: AppColors.orangeSport, // Highlight nama event pake warna brand
                        fontSize: 12,
                        fontWeight: FontWeight.w500
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Tanggal review di pojok kanan atas
              Text(
                _formatDate(review.createdAt), 
                style: const TextStyle(color: AppColors.gray500, fontSize: 10),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          const Divider(color: AppColors.deepSeaLighter, height: 1),
          const SizedBox(height: 12),

          // Bagian Rating Bintang
          _buildStarRating(review.rating),
          
          const SizedBox(height: 8),

          // Isi Komentar
          Text(
            review.comment.isNotEmpty ? review.comment : "Tidak ada komentar.", 
            style: const TextStyle(
              color: AppColors.gray300, 
              fontSize: 14,
              height: 1.5, // Spasi antar baris biar enak dibaca
            ),
          ),
        ],
      ),
    );
  }

  // Helper simpel buat nampilin bintang
  Widget _buildStarRating(int rating) {
    return Row(
      children: List.generate(5, (i) => Padding(
        padding: const EdgeInsets.only(right: 2),
        child: Icon(
          i < rating ? Icons.star : Icons.star_border_rounded,
          color: AppColors.orangeSport, // Warna bintang sesuai brand
          size: 18,
        ),
      )),
    );
  }

  // Helper buat motong tanggal biar gak kepanjangan (opsional)
  String _formatDate(String fullDate) {
    // Kalo backend ngasih format panjang (YYYY-MM-DD HH:MM:SS), kita ambil tanggalnya aja
    if (fullDate.length > 10) {
      return fullDate.substring(0, 10);
    }
    return fullDate;
  }
}