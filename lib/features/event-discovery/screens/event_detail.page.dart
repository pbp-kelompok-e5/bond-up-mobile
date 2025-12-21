import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:bond_up_mobile/core/design_system.dart';
import 'package:bond_up_mobile/features/event-discovery/data/models/event_model.dart';
import 'package:bond_up_mobile/features/event-discovery/data/services/event_discovery_service.dart';

class EventDetailScreen extends StatefulWidget{
  final Event event;
  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreen();
}

class _EventDetailScreen extends State<EventDetailScreen>{
  late EventDiscoveryService _service;
  bool _isLoading = true;
  bool _isActionLoading = false;
  String _status = 'not_participating';
  late int _currentParticipants;
  late Event _event;

  @override
  void initState() {
    super.initState();
    final request = context.read<CookieRequest>();
    _service = EventDiscoveryService(request);
    _event = widget.event;
    _currentParticipants = _event.currentParticipants;
    _fetchStatus();
  }

  // Fetch fresh data from backend (Refresh Logic)
  Future<void> _refreshEventData() async {
    // print('DEBUG: _refreshEventData called for event ID: ${_event.id}');

    // Fetch updated event details using ID
    final updatedEvent = await _service.fetchEventById(_event.id);
    // print('DEBUG: Updated event fetched: ${updatedEvent?.id}, participants: ${updatedEvent?.currentParticipants}');

    // Fetch updated status
    final updatedStatus = await _service.getParticipantStatus(int.parse(_event.id));
    // print('DEBUG: Updated status from service: $updatedStatus');

    if (mounted) {
      setState(() {
        if (updatedEvent != null) {
          _event = updatedEvent;
          // Update local participants count to match server
          _currentParticipants = updatedEvent.currentParticipants;
        }
        _status = updatedStatus;
        // print('DEBUG: State updated - _status is now: $_status');
      });
    }
  }


  Future<void> _fetchStatus() async {
    // Fetch user status ('joined', 'not_participating', etc.)
    final status = await _service.getParticipantStatus(int.parse(widget.event.id));
    if (mounted) {
      setState(() {
        _status = status;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleJoin() async {
    setState(() => _isActionLoading = true);
    
    // Panggil service
    final success = await _service.joinEvent(int.parse(widget.event.id));

    if (mounted) {
      setState(() => _isActionLoading = false);
      
      if (success) {
        ToastUtils.showSuccess(context, "Successfully joined the event!");
        
        // Jangan tunggu _refreshEventData. Ubah UI langsung karena kita tahu request sukses.
        setState(() {
          _status = 'joined'; 
          // Opsional: Tambah jumlah partisipan secara visual agar instan
          if (_currentParticipants < _event.maxParticipants) {
             _currentParticipants += 1;
          }
        });

        // Tetap lakukan refresh di background untuk sinkronisasi data yang akurat
        // Hapus delay jika tidak diperlukan, tapi delay kecil oke untuk memberi waktu server commit DB
        await Future.delayed(const Duration(milliseconds: 300));
        await _refreshEventData(); 
        
      } else {
        ToastUtils.showError(context, "Failed to join event.");
      }
    }
  }
  Future<void> _handleLeave() async {
    setState(() => _isActionLoading = true);
    final success = await _service.leaveEvent(int.parse(widget.event.id));

    if (mounted) {
      setState(() => _isActionLoading = false);
      if (success) {
        ToastUtils.showSuccess(context, "You have left the event.");
        
        // --- PERUBAHAN DI SINI (Optimistic Update) ---
        setState(() {
          _status = 'not_participating'; // Kembalikan ke status awal
           // Opsional: Kurangi jumlah partisipan secara visual
          if (_currentParticipants > 0) {
             _currentParticipants -= 1;
          }
        });

        await Future.delayed(const Duration(milliseconds: 300));
        await _refreshEventData();
      } else {
        ToastUtils.showError(context, "Failed to leave event.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate if event is full based on local state
    final bool isFull = _currentParticipants >= _event.maxParticipants;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.deepSea,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        title: const Text("Event Detail"),
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              color: AppColors.orangeSport,
              backgroundColor: AppColors.deepSea,
              onRefresh: _refreshEventData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 200,
                      child: _event.thumbnail != null && _event.thumbnail!.isNotEmpty
                          ? Image.network(
                        _event.thumbnail!,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, error, stack) => Container(
                          color: Colors.white10,
                          child: const Icon(Icons.image_not_supported, size: 50, color: Colors.white24),
                        ),
                      )
                          : Container(
                        color: AppColors.deepSea, // Placeholder menggunakan Deep Sea
                        child: const Icon(Icons.event, size: 60, color: AppColors.orangeSport),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _event.title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white, // Teks judul putih
                            ),
                          ),
                          const SizedBox(height: 8),

                          Row(
                            children: [
                              const Icon(Icons.person, size: 16, color: AppColors.orangeSport), // Aksen oranye
                              const SizedBox(width: 4),
                              Text(
                                "Organized by ${_event.organizer}",
                                style: const TextStyle(color: Colors.white70), // Teks keterangan putih pudar
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          Wrap(
                            spacing: 8,
                            children: [
                              Chip(
                                label: Text(_event.city, style: const TextStyle(color: Colors.white)),
                                avatar: const Icon(Icons.location_city, size: 16, color: Colors.white),
                                backgroundColor: AppColors.deepSea, // Chip warna Deep Sea
                                side: BorderSide.none,
                              ),
                              Chip(
                                label: Text(_event.sportType, style: const TextStyle(color: Colors.white)),
                                avatar: const Icon(Icons.sports, size: 16, color: Colors.white),
                                backgroundColor: AppColors.deepSea,
                                side: BorderSide.none,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          _buildInfoRow(Icons.calendar_today, "Date", _event.eventDate.toString().split(' ')[0]),
                          const SizedBox(height: 12),
                          _buildInfoRow(Icons.access_time, "Time", "${_event.startTime} - ${_event.endTime}"),
                          const SizedBox(height: 12),
                          _buildInfoRow(Icons.place, "Location", _event.locationName),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            Icons.group,
                            "Participants",
                            "$_currentParticipants / ${_event.maxParticipants}",
                            highlight: isFull && _status != 'joined',
                          ),

                          const Divider(height: 40, color: Colors.white10),

                          const Text(
                            "About Event",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _event.description,
                            style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.white70),
                          ),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.deepSea, // Container bawah menggunakan Deep Sea
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.orangeSport))
                    : _buildActionButton(isFull),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(bool isFull) {
    final bool eventEnded = _event.status.toLowerCase() == 'completed' ||
        _event.status.toLowerCase() == 'cancelled';

    if (_status == 'joined' || _status == 'attended' || _status == 'cancelled') {
      if (_status == 'cancelled') {
        return ElevatedButton(
          onPressed: null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white.withValues(alpha: 0.1),
            disabledBackgroundColor: Colors.white.withValues(alpha: 0.1),
            foregroundColor: Colors.white38,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text("Cancelled", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        );
      }

      if (!eventEnded) {
        return ElevatedButton(
          onPressed: _isActionLoading ? null : _handleLeave,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.buttonDanger, // Merah untuk leave
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: _isActionLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text("Leave Event", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        );
      } else {
        return ElevatedButton(
          onPressed: null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white.withValues(alpha: 0.1),
            disabledBackgroundColor: Colors.white.withValues(alpha: 0.1),
            foregroundColor: Colors.white38,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(
              _status == 'attended' ? "Attended" : "Event Ended",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
          ),
        );
      }
    } else {
      if (eventEnded) {
        return ElevatedButton(
          onPressed: null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white.withValues(alpha: 0.1),
            disabledBackgroundColor: Colors.white.withValues(alpha: 0.1),
            foregroundColor: Colors.white38,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text("Event Ended", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        );
      }

      if (isFull) {
        return ElevatedButton(
          onPressed: null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white.withValues(alpha: 0.1),
            disabledBackgroundColor: Colors.white.withValues(alpha: 0.1),
            foregroundColor: Colors.white38,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text("Event Full", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        );
      } else {
        return ElevatedButton(
          onPressed: _isActionLoading ? null : _handleJoin,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.orangeSport, // Warna utama tombol join
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: _isActionLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text("Join Event", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        );
      }
    }
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {bool highlight = false}) {
    return Row(
      children: [
        Icon(icon, color: highlight ? Colors.red : AppColors.orangeSport, size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.white38)),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: highlight ? Colors.red : Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
}