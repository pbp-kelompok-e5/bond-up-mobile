import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:bond_up_mobile/core/design_system.dart';
import 'package:bond_up_mobile/features/reviews/data/models/review_participant.dart';
import 'package:bond_up_mobile/core/constants/api_constants.dart';

class EventReviewsPage extends StatefulWidget {
  final int eventId;
  final String eventTitle;

  const EventReviewsPage({
    super.key,
    required this.eventId,
    required this.eventTitle,
  });

  @override
  State<EventReviewsPage> createState() => _EventReviewsPageState();
}

class _EventReviewsPageState extends State<EventReviewsPage> {
  // State variables buat nge-track status loading dan error
  bool _isLoadingData = true;
  bool _isSubmitting = false;
  String? _errorMessage;
  
  // List data partisipan yang bakal kita review
  List<ReviewParticipant> _participants = [];
  
  // Map buat nyimpen nilai rating (key: id_user, value: rating 1-5)
  final Map<int, int> _ratings = {};
  
  // Map buat nyimpen controller textfield (biar tiap user punya input sendiri)
  final Map<int, TextEditingController> _commentControllers = {};

  @override
  void dispose() {
    // Jangan lupa bersihin controller biar gak memory leak
    for (var controller in _commentControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  // Fungsi buat ngambil data partisipan dari API Django
  Future<void> _fetchParticipants() async {
    final request = context.read<CookieRequest>();
    final url = '${ApiConstants.baseUrl}/reviews/api/event/${widget.eventId}/participants/';

    try {
      final response = await request.get(url);
      
      if (response != null && response['participants'] != null) {
        final List<ReviewParticipant> loaded = (response['participants'] as List)
            .map((item) => ReviewParticipant.fromJson(item))
            .toList();

        setState(() {
          _participants = loaded;
          // Inisialisasi controller buat tiap partisipan yang ke-load
          for (var p in loaded) {
            _commentControllers[p.id] = TextEditingController();
          }
          _isLoadingData = false;
        });
      }
    } catch (e) {
      // Kalo error, matiin loading dan kasih tau usernya
      setState(() {
        _isLoadingData = false;
        _errorMessage = "Waduh, gagal memuat data: $e";
      });
    }
  }

  // Fungsi buat kirim semua review sekaligus
  Future<void> _submitReviews() async {
    if (!_canSubmit) return; // Cek dulu, ada yang di-rate gak?
    
    setState(() => _isSubmitting = true);
    final request = context.read<CookieRequest>();

    // Kita susun data form-nya sesuai format yang diminta backend
    final Map<String, dynamic> formData = {};
    for (var p in _participants) {
      // Cuma masukin data kalo user tersebut udah dikasih rating
      if (_ratings.containsKey(p.id)) {
        formData['rating_${p.id}'] = _ratings[p.id].toString();
        formData['comment_${p.id}'] = _commentControllers[p.id]?.text ?? '';
      }
    }

    try {
      final response = await request.post(
        '${ApiConstants.baseUrl}/reviews/ajax/event/${widget.eventId}/create/',
        formData,
      );

      if (response['ok'] == true) {
        if (mounted) {
          ToastUtils.showSuccess(context, "Mantap! Review berhasil dikirim.");
          Navigator.pop(context); // Balik ke halaman sebelumnya
        }
      } else {
        if (mounted) ToastUtils.showError(context, response['error'] ?? "Gagal submit review.");
      }
    } catch (e) {
      if (mounted) ToastUtils.showError(context, "Masalah koneksi: $e");
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // Getter buat ngecek minimal ada satu orang yang udah di-rate
  bool get _canSubmit => _ratings.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _fetchParticipants(); // Langsung tarik data pas halaman dibuka
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepSea, // Pakai warna utama brand
      appBar: AppBar(
        backgroundColor: AppColors.deepSea,
        iconTheme: const IconThemeData(color: AppColors.white),
        title: Text(
          widget.eventTitle,
          style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: _isLoadingData 
          ? const Center(child: CircularProgressIndicator(color: AppColors.orangeSport))
          : _errorMessage != null
            ? Center(
                child: Text(
                  _errorMessage!, 
                  style: const TextStyle(color: AppColors.gray300)
                )
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Judul Kecil di atas
                    const Text(
                      "Rate Your Partners",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Gimana pengalaman main bareng mereka? Kasih rating yuk!",
                      style: TextStyle(color: AppColors.gray400),
                    ),
                    const SizedBox(height: 24),

                    // List Cards
                    _participants.isEmpty 
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 40),
                            child: Text("Tidak ada partisipan lain.", style: TextStyle(color: AppColors.gray400)),
                          ),
                        )
                      : Column(
                          children: _participants.map((p) => _buildParticipantCard(p)).toList(),
                        ),
                    
                    const SizedBox(height: 32),
                    
                    // Tombol Submit
                    if (_participants.isNotEmpty)
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _canSubmit && !_isSubmitting ? _submitReviews : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.orangeSport,
                            disabledBackgroundColor: AppColors.gray600,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                          child: _isSubmitting 
                            ? const SizedBox(
                                height: 20, 
                                width: 20, 
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                              )
                            : const Text(
                                "Kirim Review",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                        ),
                      ),
                    const SizedBox(height: 40), // Space bawah biar gak mentok
                  ],
                ),
              ),
    );
  }

  // Widget terpisah buat kartu user biar kode build utama lebih rapi
  Widget _buildParticipantCard(ReviewParticipant participant) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.deepSeaLight, // Warna kartu sedikit lebih terang dari background
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.deepSeaLighter, // Border tipis biar dimensi lebih dapet
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bagian Header: Avatar & Nama
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.orangeSport, width: 2), // Ring orange di foto
                ),
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.gray700,
                  backgroundImage: NetworkImage(
                    participant.profileImageUrl ?? 
                    "https://ui-avatars.com/api/?name=${participant.username}&background=random"
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      participant.username,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                    const Text(
                      "Participant",
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.gray400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          const Divider(color: AppColors.deepSeaLighter, height: 1),
          const SizedBox(height: 16),

          // Bagian Bintang Rating
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final int starValue = index + 1;
                final bool isSelected = starValue <= (_ratings[participant.id] ?? 0);
                
                return GestureDetector(
                  onTap: () {
                    // Update state pas bintang diklik
                    setState(() => _ratings[participant.id] = starValue);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      isSelected ? Icons.star : Icons.star_border_rounded,
                      // Kalau kepilih pake warna Orange Sport, kalau belum abu-abu
                      color: isSelected ? AppColors.orangeSport : AppColors.gray500,
                      size: 32,
                    ),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 20),

          // Input Komentar
          TextField(
            controller: _commentControllers[participant.id],
            style: const TextStyle(color: AppColors.white),
            maxLines: 2,
            minLines: 1,
            decoration: InputDecoration(
              hintText: "Tulis komentar (opsional)...",
              hintStyle: const TextStyle(color: AppColors.gray500),
              filled: true,
              fillColor: AppColors.deepSea, // Input field lebih gelap dari kartu
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.orangeSport, width: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}