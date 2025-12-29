import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:bond_up_mobile/core/design_system.dart';
import 'package:bond_up_mobile/features/reviews/data/models/user_written_review.dart';
import 'package:bond_up_mobile/core/constants/api_constants.dart';

class UserWrittenReviewsPage extends StatefulWidget {
  const UserWrittenReviewsPage({super.key});

  @override
  State<UserWrittenReviewsPage> createState() => _UserWrittenReviewsPageState();
}

class _UserWrittenReviewsPageState extends State<UserWrittenReviewsPage> {
  // Variable buat nandain kalo lagi ada proses update/delete biar UI gak freeze doang
  bool _isProcessing = false;

  // 1. Ambil data review yang pernah kita tulis
  Future<List<UserWrittenReview>> fetchMyWrittenReviews(CookieRequest request) async {
    try {
      final response = await request.get('${ApiConstants.baseUrl}/reviews/api/my-reviews/');
      
      List<UserWrittenReview> listReview = [];
      if (response['status'] == 'success') {
        for (var d in response['data']) {
          if (d != null) {
            listReview.add(UserWrittenReview.fromJson(d));
          }
        }
      }
      return listReview;
    } catch (e) {
      // Kalo gagal fetch, balikin list kosong aja dulu
      return [];
    }
  }

  // 2. Hapus review
  Future<void> deleteMyReview(CookieRequest request, int id) async {
    setState(() => _isProcessing = true); // Nyalain loading
    try {
      final response = await request.post('${ApiConstants.baseUrl}/reviews/ajax/delete/$id/', {});
      if (response['ok']) {
        if (mounted) {
          ToastUtils.showSuccess(context, "Review berhasil dihapus!");
          setState(() {}); // Refresh UI
        }
      } else {
        if (mounted) ToastUtils.showError(context, "Gagal menghapus review.");
      }
    } catch (e) {
      if (mounted) ToastUtils.showError(context, "Error: $e");
    } finally {
      if (mounted) setState(() => _isProcessing = false); // Matiin loading
    }
  }

  // 3. Update review (Edit)
  Future<void> updateMyReview(CookieRequest request, int id, int rating, String comment) async {
    setState(() => _isProcessing = true);
    try {
      final response = await request.post(
        '${ApiConstants.baseUrl}/reviews/ajax/update/$id/',
        {
          'rating': rating.toString(),
          'comment': comment,
        },
      );

      if (response['ok']) {
        if (mounted) {
          ToastUtils.showSuccess(context, "Review berhasil diupdate!");
          setState(() {}); 
        }
      } else {
        if (mounted) ToastUtils.showError(context, "Gagal update review.");
      }
    } catch (e) {
      if (mounted) ToastUtils.showError(context, "Error: $e");
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: AppColors.deepSea, // Warna background konsisten
      appBar: AppBar(
        title: const Text(
          "My Written Reviews", 
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)
        ),
        backgroundColor: AppColors.deepSea,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Stack(
        children: [
          FutureBuilder<List<UserWrittenReview>>(
            future: fetchMyWrittenReviews(request),
            builder: (context, snapshot) {
              // Loading state awal
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: AppColors.orangeSport));
              }
              
              // Kalo datanya kosong atau null
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.rate_review_outlined, size: 64, color: AppColors.gray500),
                      SizedBox(height: 16),
                      Text("Kamu belum nulis review apapun.", style: TextStyle(color: AppColors.gray400)),
                    ],
                  ),
                );
              }

              // Render list review
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: snapshot.data!.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final review = snapshot.data![index];
                  return _buildReviewCard(context, request, review);
                },
              );
            },
          ),
          
          // Overlay loading pas lagi delete/update biar user gak klik-klik sembarangan
          if (_isProcessing)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: const Center(child: CircularProgressIndicator(color: AppColors.orangeSport)),
            ),
        ],
      ),
    );
  }

  // Widget kartu review custom biar lebih rapi layoutnya
  Widget _buildReviewCard(BuildContext context, CookieRequest request, UserWrittenReview review) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.deepSeaLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Judul Event
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.deepSeaLighter,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.event_note, color: AppColors.orangeSport, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.eventTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        review.eventTitle.length.toString(),
                        style: TextStyle(
                          color: review.eventTitle.length > 100 ? Colors.red : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        review.createdAt,
                        style: const TextStyle(color: AppColors.gray500, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(color: AppColors.deepSea, height: 1),

          // Body: Review Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text("Untuk: ", style: TextStyle(color: AppColors.gray400)),
                    Text(
                      review.revieweeName, 
                      style: const TextStyle(
                        color: AppColors.white, 
                        fontWeight: FontWeight.bold
                      )
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildStaticRating(review.rating),
                const SizedBox(height: 12),
                Text(
                  review.comment.isNotEmpty ? review.comment : "Tidak ada komentar.",
                  style: const TextStyle(color: AppColors.gray200, height: 1.4),
                ),
              ],
            ),
          ),

          // Footer: Action Buttons (Edit & Delete)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Tombol Edit - MENGGUNAKAN statusCompleted (Biru)
                OutlinedButton.icon(
                  onPressed: () => _showEditDialog(request, review),
                  icon: const Icon(Icons.edit, size: 18, color: AppColors.statusCompleted),
                  label: const Text("Edit", style: TextStyle(color: AppColors.statusCompleted)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.statusCompleted),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(width: 12),
                // Tombol Delete - MENGGUNAKAN buttonDanger (Merah)
                OutlinedButton.icon(
                  onPressed: () => _confirmDelete(request, review.id),
                  icon: const Icon(Icons.delete, size: 18, color: AppColors.buttonDanger),
                  label: const Text("Delete", style: TextStyle(color: AppColors.buttonDanger)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.buttonDanger),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Functions & Dialogs ---

  void _showEditDialog(CookieRequest request, UserWrittenReview review) {
    int tempRating = review.rating;
    TextEditingController commentController = TextEditingController(text: review.comment);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          backgroundColor: AppColors.deepSeaLight, // Dialog gelap
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Edit Review", style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Ganti rating kamu:", style: TextStyle(color: AppColors.gray400)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) => IconButton(
                  icon: Icon(
                    i < tempRating ? Icons.star : Icons.star_border_rounded,
                    color: AppColors.orangeSport,
                    size: 32,
                  ),
                  onPressed: () => setStateDialog(() => tempRating = i + 1),
                )),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: commentController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Update komentar...",
                  hintStyle: const TextStyle(color: AppColors.gray500),
                  filled: true,
                  fillColor: AppColors.deepSea,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text("Batal", style: TextStyle(color: AppColors.gray400))
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.orangeSport),
              onPressed: () {
                Navigator.pop(context);
                updateMyReview(request, review.id, tempRating, commentController.text);
              },
              child: const Text("Simpan", style: TextStyle(color: Colors.white)),
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
        backgroundColor: AppColors.deepSeaLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Hapus Review?", style: TextStyle(color: Colors.white)),
        content: const Text(
          "Yakin mau menghapus review ini? Tindakan ini tidak bisa dibatalkan.",
          style: TextStyle(color: AppColors.gray300)
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text("Batal", style: TextStyle(color: AppColors.gray400))
          ),
          TextButton(
            onPressed: () { 
              Navigator.pop(context); 
              deleteMyReview(request, id); 
            },
            child: const Text("Hapus", style: TextStyle(color: AppColors.buttonDanger)),
          ),
        ],
      ),
    );
  }

  // Widget kecil buat nampilin bintang yang gak bisa diklik (read-only)
  Widget _buildStaticRating(int rating) {
    return Row(
      children: List.generate(5, (i) => Icon(
        i < rating ? Icons.star : Icons.star_border_rounded,
        color: AppColors.orangeSport, 
        size: 20,
      )),
    );
  }
}