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
  bool _isLoadingData = true;
  bool _isSubmitting = false;
  String? _errorMessage;
  List<ReviewParticipant> _participants = [];
  
  final Map<int, int> _ratings = {};
  final Map<int, TextEditingController> _commentControllers = {};

  @override
  void dispose() {
    for (var controller in _commentControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

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
          for (var p in loaded) {
            _commentControllers[p.id] = TextEditingController();
          }
          _isLoadingData = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingData = false;
        _errorMessage = "Gagal memuat data: $e";
      });
    }
  }

  Future<void> _submitReviews() async {
    if (!_canSubmit) return;
    
    setState(() => _isSubmitting = true);
    final request = context.read<CookieRequest>();

    final Map<String, dynamic> formData = {};
    for (var p in _participants) {
      if (_ratings.containsKey(p.id)) {
        formData['rating_${p.id}'] = _ratings[p.id].toString();
        formData['comment_${p.id}'] = _commentControllers[p.id]?.text ?? 'No comment';
      }
    }

    try {
      final response = await request.post(
  '${ApiConstants.baseUrl}/reviews/ajax/event/${widget.eventId}/create/',
  formData,
);

      if (response['ok'] == true) {
        if (mounted) {
          ToastUtils.showSuccess(context, "All reviews submitted!");
          Navigator.pop(context);
        }
      } else {
        if (mounted) ToastUtils.showError(context, response['error'] ?? "Failed");
      }
    } catch (e) {
      if (mounted) ToastUtils.showError(context, "Network Error: $e");
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  bool get _canSubmit => _ratings.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _fetchParticipants();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepSea, // Mengikuti tema Deep Sea
      appBar: AppBar(
        title: Text(widget.eventTitle),
      ),
      body: _isLoadingData 
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
            ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.white)))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    DeepSeaCard(
                      header: const Text("Rate Your Partners"),
                      body: _participants.isEmpty 
                        ? const Text("No one left to review.")
                        : Column(
                            children: _participants.map((p) => _buildParticipantItem(p)).toList(),
                          ),
                    ),
                    const SizedBox(height: 20),
                    if (_participants.isNotEmpty)
                      AppButton(
                        text: "Submit All Reviews",
                        isFullWidth: true,
                        isLoading: _isSubmitting,
                        onPressed: _canSubmit ? _submitReviews : null,
                      ),
                  ],
                ),
              ),
    );
  }

  Widget _buildParticipantItem(ReviewParticipant participant) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.deepSeaLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(backgroundImage: NetworkImage(participant.profileImageUrl ?? "https://ui-avatars.com/api/?name=${participant.username}")),
              const SizedBox(width: 12),
              Text(participant.username, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) => IconButton(
              icon: Icon(
                i < (_ratings[participant.id] ?? 0) ? Icons.star : Icons.star_border,
                color: AppColors.orangeSport,
                size: 30,
              ),
              onPressed: () => setState(() => _ratings[participant.id] = i + 1),
            )),
          ),
          AppTextField(
            controller: _commentControllers[participant.id],
            hint: "Optional comment...",
          ),
        ],
      ),
    );
  }
}