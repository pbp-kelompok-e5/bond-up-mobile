import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:bond_up_mobile/core/design_system.dart';
import 'package:bond_up_mobile/features/event-discovery/data/models/event_model.dart';
import 'package:bond_up_mobile/features/event-discovery/data/services/event_discovery_service.dart';
import 'package:bond_up_mobile/main.dart';
import 'package:bond_up_mobile/core/widgets/navigation/app_drawer.dart';
import 'package:bond_up_mobile/features/auth/data/services/auth_service.dart';
import 'package:bond_up_mobile/features/auth/presentation/screens/login_screen.dart';


class EventDetailScreen extends StatefulWidget{
  final Event event;
  const EventDetailScreen({super.key, required this.event});

  State<EventDetailScreen> createState() => _EventDetailScreen();
}

class _EventDetailScreen extends State<EventDetailScreen>{
  late EventDiscoveryService _service;
  bool _isLoading = true;
  bool _isActionLoading = false;
  String _status = 'not_participating';
  late int _currentParticipants;

  @override
  void initState() {
    super.initState();
    final request = context.read<CookieRequest>();
    _service = EventDiscoveryService(request);
    _currentParticipants = widget.event.currentParticipants;
    _fetchStatus();
  }

  // Logout
  Future<void> _handleLogout() async {
    // Mengambil request dari provider
    final request = context.read<CookieRequest>();
    final authService = AuthService(request);

    // Melakukan logout ke backend
    await authService.logout();

    // Cek apakah widget masih aktif sebelum menggunakan context
    if (!mounted) return;

    // Menampilkan pesan sukses
    try {
      // Asumsi kamu punya class ToastUtils di design_system.dart
      ToastUtils.showSuccess(context, 'Logged out successfully');
    } catch (e) {
      // Fallback jika ToastUtils belum siap
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged out successfully')),
      );
    }

    // Navigasi kembali ke Login Screen dan menghapus history route sebelumnya
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
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
    final success = await _service.joinEvent(int.parse(widget.event.id));

    if (mounted) {
      setState(() => _isActionLoading = false);
      if (success) {
        ToastUtils.showSuccess(context, "Successfully joined the event!");
        setState(() {
          _status = 'joined';
          _currentParticipants++;
        });
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
        setState(() {
          _status = 'not_participating';
          _currentParticipants--;
        });
      } else {
        ToastUtils.showError(context, "Failed to leave event.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate if event is full
    final bool isFull = _currentParticipants >= widget.event.maxParticipants;

    return Scaffold(
      appBar: AppBar(
        // UBAH WARNA DI SINI:
        // Gunakan warna primary agar lebih tegas sebagai background
        backgroundColor: Theme.of(context).colorScheme.primary,
        // foregroundColor memaksa semua text dan icon di AppBar (termasuk drawer) menjadi Putih
        foregroundColor: Colors.white,
        title: const Text("Event Detail"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            // Aksi saat tombol logout ditekan
            onPressed: _handleLogout,
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event Thumbnail
                  SizedBox(
                    width: double.infinity,
                    height: 200,
                    child: widget.event.thumbnail != null && widget.event.thumbnail!.isNotEmpty
                        ? Image.network(
                      widget.event.thumbnail!,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, error, stack) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                      ),
                    )
                        : Container(
                      color: Colors.blueAccent.withOpacity(0.2),
                      child: const Icon(Icons.event, size: 60, color: Colors.blueAccent),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          widget.event.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Organizer
                        Row(
                          children: [
                            const Icon(Icons.person, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              "Organized by ${widget.event.organizer}",
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Tags (City, Sport)
                        Wrap(
                          spacing: 8,
                          children: [
                            Chip(
                              label: Text(widget.event.city),
                              avatar: const Icon(Icons.location_city, size: 16),
                              backgroundColor: Colors.blue[50],
                            ),
                            Chip(
                              label: Text(widget.event.sportType),
                              avatar: const Icon(Icons.sports, size: 16),
                              backgroundColor: Colors.orange[50],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Info Grid
                        _buildInfoRow(Icons.calendar_today, "Date", widget.event.eventDate.toString().split(' ')[0]),
                        const SizedBox(height: 12),
                        _buildInfoRow(Icons.access_time, "Time", "${widget.event.startTime} - ${widget.event.endTime}"),
                        const SizedBox(height: 12),
                        _buildInfoRow(Icons.place, "Location", widget.event.locationName),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          Icons.group,
                          "Participants",
                          "$_currentParticipants / ${widget.event.maxParticipants}",
                          highlight: isFull && _status != 'joined',
                        ),

                        const Divider(height: 40),

                        // Description
                        const Text(
                          "About Event",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.event.description,
                          style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
                        ),
                        const SizedBox(height: 80), // Space for bottom bar
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Fixed Bottom Button Area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
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
                    ? const Center(child: CircularProgressIndicator())
                    : _buildActionButton(isFull),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(bool isFull) {
    if (_status == 'joined') {
      // Leave Button
      return ElevatedButton(
        onPressed: _isActionLoading ? null : _handleLeave,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red[50],
          foregroundColor: Colors.red,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: _isActionLoading
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : const Text("Leave Event", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      );
    } else {
      // Join Button
      if (isFull) {
        // Full State
        return ElevatedButton(
          onPressed: null, // Disabled
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[300],
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text("Event Full", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        );
      } else {
        // Active Join State
        return ElevatedButton(
          onPressed: _isActionLoading ? null : _handleJoin,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor, // Use your app's primary color
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
        Icon(icon, color: highlight ? Colors.red : Colors.grey[600], size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: highlight ? Colors.red : Colors.black,
              ),
            ),
          ],
        ),
      ],
    );
  }
}