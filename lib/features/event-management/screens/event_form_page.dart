import 'package:bond_up_mobile/core/constants/app_constants.dart';
import 'package:bond_up_mobile/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../services/event_service.dart';
import '../models/event.dart';

/// Layar untuk membuat acara baru atau mengubah acara yang sudah ada.
class EventFormPage extends StatefulWidget {
  /// Objek acara yang akan diubah. Jika null, maka acara baru akan dibuat.
  final Event? event;

  /// Membuat [EventFormPage].
  ///
  /// Jika [event] diberikan, formulir akan terisi otomatis untuk proses penyuntingan.
  const EventFormPage({super.key, this.event});

  @override
  State<EventFormPage> createState() => _EventFormPageState();
}

class _EventFormPageState extends State<EventFormPage> {
  final _formKey = GlobalKey<FormState>();

  String _title = "";
  String _description = "";
  String? _sportType;
  String _thumbnail = "";
  String? _city;
  String _locationName = "";
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  DateTime? _eventDate;
  int? _maxParticipants;

  /// Mengembalikan nilai true jika sedang mengubah acara yang sudah ada, false jika sebaliknya.
  bool get _editing => widget.event != null;

  @override
  void initState() {
    super.initState();
    // Mengisi field formulir jika ada data acara yang diberikan untuk diubah.
    if (_editing) {
      final e = widget.event!;
      _title = e.title;
      _description = e.description;
      _sportType = e.sportType;
      _thumbnail = e.thumbnail;
      _city = e.city;
      _locationName = e.locationName;
      _eventDate = e.eventDate;
      _maxParticipants = e.maxParticipants;

      try {
        _startTime = TimeOfDay.fromDateTime(DateFormat.Hms().parse(e.startTime));
        _endTime = TimeOfDay.fromDateTime(DateFormat.Hms().parse(e.endTime));
      } catch (_) {
        // Fallback jika proses parsing waktu gagal.
        _startTime = TimeOfDay.now();
        _endTime = TimeOfDay.now();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final request = context.watch<CookieRequest>();
    final service = EventService(request);

    return Scaffold(
      appBar: AppBar(
        title: Text(_editing ? "Edit Event" : "Create Event"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Field teks untuk judul acara.
              _buildFormField(
                label: "Title",
                initialValue: _title,
                onSaved: (v) => _title = v!,
                validator: (v) => (v == null || v.isEmpty) ? "Title cannot be empty" : null,
              ),
              // Field teks untuk deskripsi acara.
              _buildFormField(
                label: "Description",
                initialValue: _description,
                maxLines: 3,
                onSaved: (v) => _description = v!,
                validator: (v) => (v == null || v.isEmpty) ? "Description cannot be empty" : null,
              ),
              // Dropdown untuk memilih jenis olahraga.
              _buildDropdownField(
                label: "Sport Type",
                value: _sportType,
                items: AppConstants.sortedSports,
                onChanged: (v) => setState(() => _sportType = v),
              ),
              // Dropdown untuk memilih kota.
              _buildDropdownField(
                label: "City",
                value: _city,
                items: AppConstants.sortedCities,
                onChanged: (v) => setState(() => _city = v),
              ),
              // Field teks untuk nama lokasi.
              _buildFormField(
                label: "Location Name",
                initialValue: _locationName,
                onSaved: (v) => _locationName = v!,
                validator: (v) => (v == null || v.isEmpty) ? "Location cannot be empty" : null,
              ),
              // Field pemilih tanggal (date picker) untuk tanggal acara.
              _buildDatePickerField(context),
              Row(
                children: [
                  // Pemilih waktu untuk waktu mulai.
                  Expanded(child: _buildTimePickerField(context, isStart: true)),
                  const SizedBox(width: 16),
                  // Pemilih waktu untuk waktu selesai.
                  Expanded(child: _buildTimePickerField(context, isStart: false)),
                ],
              ),
              // Field teks untuk jumlah maksimum peserta.
              _buildFormField(
                label: "Max Participants",
                initialValue: _maxParticipants?.toString() ?? "",
                keyboardType: TextInputType.number,
                onSaved: (v) => _maxParticipants = int.tryParse(v!),
                validator: (v) {
                  if (v == null || v.isEmpty) return "Cannot be empty";
                  if (int.tryParse(v) == null) return "Must be a number";
                  if (int.parse(v) < 2) return "Must be at least 2";
                  if (int.parse(v) > 1000) return "Must be at most 1000";
                  return null;
                },
              ),
              // Field teks untuk URL thumbnail.
              _buildFormField(
                label: "Thumbnail URL",
                initialValue: _thumbnail,
                onSaved: (v) => _thumbnail = v!,
                validator: (v) => null, // Thumbnail bersifat opsional
              ),
              const SizedBox(height: 32),
              // Tombol untuk membuat atau menyimpan perubahan acara.
              ElevatedButton.icon(
                icon: Icon(_editing ? Icons.save : Icons.add_circle),
                label: Text(_editing ? "Save Changes" : "Create Event"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.orangeSport,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: theme.textTheme.labelLarge,
                ),
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  _formKey.currentState!.save();

                  // Validasi waktu pembuatan: tidak bisa membuat acara di masa lalu.
                  if (_eventDate != null &&
                      _startTime != null &&
                      DateUtils.dateOnly(_eventDate!).isAtSameMomentAs(DateUtils.dateOnly(DateTime.now()))) {
                    final now = TimeOfDay.now();
                    if (_startTime!.hour < now.hour || (_startTime!.hour == now.hour && _startTime!.minute <= now.minute)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Cannot create an event in the past.")),
                      );
                      return;
                    }
                  }

                  // Validasi rentang waktu: waktu selesai harus setelah waktu mulai.
                  if (_startTime != null && _endTime != null) {
                    if (_endTime!.hour < _startTime!.hour ||
                        (_endTime!.hour == _startTime!.hour && _endTime!.minute <= _startTime!.minute)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("End time must be after start time.")),
                      );
                      return;
                    }
                  }

                  // Menyiapkan payload untuk panggilan API.
                  final payload = {
                    "title": _title,
                    "description": _description,
                    "sport_type": _sportType,
                    "thumbnail": _thumbnail,
                    "city": _city,
                    "location_name": _locationName,
                    "start_time": _startTime?.to24HourFormat(),
                    "end_time": _endTime?.to24HourFormat(),
                    "event_date": DateFormat('yyyy-MM-dd').format(_eventDate ?? DateTime.now()),
                    "max_participants": _maxParticipants ?? 2,
                  };
                  
                  // Panggil API untuk membuat atau memperbarui acara.
                  final res = _editing
                      ? await service.updateEvent(widget.event!.id, payload)
                      : await service.createEvent(payload);

                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(res["message"] ?? "Success")),
                  );

                  // Menutup halaman dan mengirimkan indikasi sukses.
                  Navigator.pop(context, true);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Membangun [TextFormField] umum.
  Widget _buildFormField({
    required String label,
    required FormFieldSetter<String> onSaved,
    String initialValue = "",
    FormFieldValidator<String>? validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: initialValue,
        onSaved: onSaved,
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  /// Membangun field formulir dropdown.
  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<MapEntry<String, String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(labelText: label),
        items: items
            .map((entry) => DropdownMenuItem(value: entry.key, child: Text(entry.value)))
            .toList(),
        onChanged: onChanged,
        validator: (v) => (v == null || v.isEmpty) ? "$label cannot be empty" : null,
      ),
    );
  }

  /// Membangun field pemilih tanggal (date picker).
  Widget _buildDatePickerField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: TextEditingController(
          text: _eventDate == null ? '' : DateFormat('d MMMM yyyy').format(_eventDate!),
        ),
        readOnly: true,
        decoration: InputDecoration(
          labelText: 'Event Date',
          suffixIcon: const Icon(Icons.calendar_month),
          border: Theme.of(context).inputDecorationTheme.border,
        ),
        onTap: () async {
          // Menampilkan pemilih tanggal dan memperbarui state.
          final pickedDate = await showDatePicker(
            context: context,
            initialDate: _eventDate ?? DateTime.now(),
            firstDate: DateUtils.dateOnly(DateTime.now()),
            lastDate: DateTime(2101),
          );
          if (pickedDate != null) {
            setState(() => _eventDate = pickedDate);
          }
        },
        validator: (v) => (_eventDate == null) ? "Date cannot be empty" : null,
      ),
    );
  }

  /// Membangun field pemilih waktu (time picker).
  ///
  /// [isStart] menentukan apakah field ini untuk waktu mulai atau waktu selesai.
  Widget _buildTimePickerField(BuildContext context, {required bool isStart}) {
    final time = isStart ? _startTime : _endTime;
    final label = isStart ? 'Start Time' : 'End Time';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: TextEditingController(text: time?.format(context) ?? ''),
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.access_time),
          border: Theme.of(context).inputDecorationTheme.border,
        ),
        onTap: () async {
          // Menampilkan pemilih waktu dan memperbarui state.
          final pickedTime = await showTimePicker(
            context: context,
            initialTime: time ?? TimeOfDay.now(),
          );
          if (pickedTime != null) {
            setState(() {
              if (isStart) {
                _startTime = pickedTime;
              } else {
                _endTime = pickedTime;
              }
            });
          }
        },
        validator: (v) => (time == null) ? "Time cannot be empty" : null,
      ),
    );
  }
}

/// Ekstensi metode untuk [TimeOfDay].
extension TimeOfDayExtension on TimeOfDay {
  /// Mengonversi [TimeOfDay] ke string format 24 jam ("HH:MM:00").
  String to24HourFormat() {
    final hour = this.hour.toString().padLeft(2, '0');
    final minute = this.minute.toString().padLeft(2, '0');
    return '$hour:$minute:00';
  }
}