import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/event_location_result.dart';
import '../../domain/entities/event_entity.dart';
import '../bloc/event_bloc.dart';
import 'event_location_picker_page.dart';

class EventFormPage extends StatefulWidget {
  final String currentUserId;
  final EventEntity? event;

  const EventFormPage({super.key, required this.currentUserId, this.event});

  @override
  State<EventFormPage> createState() => _EventFormPageState();
}

class _EventFormPageState extends State<EventFormPage> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _priceController = TextEditingController(text: '0');
  final _maxParticipantsController = TextEditingController();

  DateTime _eventDate = DateTime.now().add(const Duration(days: 1));
  bool _isOnline = false;
  EventLocationResult? _selectedLocation;

  bool get _isEditing => widget.event != null;

  @override
  void initState() {
    super.initState();
    final event = widget.event;
    if (event != null) {
      _nameController.text = event.name;
      _descriptionController.text = event.description ?? '';
      _locationController.text = event.address ?? event.location ?? '';
      _priceController.text = event.price.toStringAsFixed(0);
      _maxParticipantsController.text = event.maxParticipants?.toString() ?? '';
      _eventDate = event.eventDate;
      _isOnline = event.isOnline;
      if (event.hasCoordinates) {
        _selectedLocation = EventLocationResult(
          latitude: event.latitude!,
          longitude: event.longitude!,
          address: event.address ?? event.location,
          placeId: event.placeId,
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    _maxParticipantsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          _isEditing ? 'Edit Event' : 'Buat Event',
          style: AppTextStyles.title,
        ),
      ),
      body: Form(
        child: Builder(
          builder: (formContext) => ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            children: [
              _FieldCard(
                child: TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama event',
                    border: InputBorder.none,
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Nama event wajib diisi.'
                      : null,
                ),
              ),
              const SizedBox(height: 12),
              _FieldCard(
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _isOnline,
                  onChanged: (value) => setState(() => _isOnline = value),
                  activeThumbColor: AppColors.primary,
                  title: Text('Event online', style: AppTextStyles.body),
                  subtitle: Text(
                    _isOnline
                        ? 'Event online tidak wajib punya titik peta.'
                        : 'Event offline wajib memilih lokasi di peta.',
                    style: AppTextStyles.bodySmall,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _DatePickerCard(date: _eventDate, onTap: _pickDateTime),
              const SizedBox(height: 12),
              if (!_isOnline)
                _LocationSection(
                  controller: _locationController,
                  selectedLocation: _selectedLocation,
                  onPickLocation: _pickLocation,
                ),
              if (!_isOnline) const SizedBox(height: 12),
              _FieldCard(
                child: TextFormField(
                  controller: _maxParticipantsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Maksimal peserta',
                    hintText: 'Kosongkan jika tidak dibatasi',
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _FieldCard(
                child: TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Harga',
                    prefixText: 'Rp ',
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _FieldCard(
                child: TextFormField(
                  controller: _descriptionController,
                  minLines: 3,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi',
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => _submit(formContext),
                  icon: const Icon(Icons.save_rounded, size: 18),
                  label: Text(
                    _isEditing ? 'Simpan Perubahan' : 'Buat Event',
                    style: AppTextStyles.buttonPrimary,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _eventDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_eventDate),
    );
    if (time == null || !mounted) return;

    setState(() {
      _eventDate = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.push<EventLocationResult>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            EventLocationPickerPage(initialLocation: _selectedLocation),
      ),
    );
    if (result == null || !mounted) return;
    setState(() {
      _selectedLocation = result;
      _locationController.text =
          result.address ??
          '${result.latitude.toStringAsFixed(6)}, ${result.longitude.toStringAsFixed(6)}';
    });
  }

  void _submit(BuildContext formContext) {
    if (Form.maybeOf(formContext)?.validate() != true) return;
    if (!_isOnline && _selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih lokasi event di peta terlebih dahulu.'),
        ),
      );
      return;
    }

    final location = _selectedLocation;
    final event = EventEntity(
      id: widget.event?.id ?? '',
      creatorId: widget.event?.creatorId ?? widget.currentUserId,
      name: _nameController.text.trim(),
      icon: widget.event?.icon ?? 'event',
      color: widget.event?.color ?? '#FF7600',
      eventDate: _eventDate,
      location: _isOnline ? null : _locationController.text.trim(),
      latitude: _isOnline ? null : location?.latitude,
      longitude: _isOnline ? null : location?.longitude,
      placeId: _isOnline ? null : location?.placeId,
      address: _isOnline ? null : _locationController.text.trim(),
      isOnline: _isOnline,
      maxParticipants: int.tryParse(_maxParticipantsController.text.trim()),
      currentParticipants: widget.event?.currentParticipants ?? 0,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      price: double.tryParse(_priceController.text.trim()) ?? 0,
      isJoinedByMe: widget.event?.isJoinedByMe ?? false,
      createdAt: widget.event?.createdAt ?? DateTime.now(),
      creatorName: widget.event?.creatorName,
      creatorPhoto: widget.event?.creatorPhoto,
    );

    context.read<EventBloc>().add(
      _isEditing ? UpdateEvent(event: event) : CreateEvent(event: event),
    );
    Navigator.pop(context, true);
  }
}

class _LocationSection extends StatelessWidget {
  final TextEditingController controller;
  final EventLocationResult? selectedLocation;
  final VoidCallback onPickLocation;

  const _LocationSection({
    required this.controller,
    required this.selectedLocation,
    required this.onPickLocation,
  });

  @override
  Widget build(BuildContext context) {
    return _FieldCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: controller,
            minLines: 1,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Alamat lokasi',
              border: InputBorder.none,
            ),
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Alamat lokasi wajib diisi.'
                : null,
          ),
          const SizedBox(height: 10),
          if (selectedLocation != null)
            Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    height: 140,
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(
                          selectedLocation!.latitude,
                          selectedLocation!.longitude,
                        ),
                        zoom: 15,
                      ),
                      zoomControlsEnabled: false,
                      myLocationButtonEnabled: false,
                      scrollGesturesEnabled: false,
                      rotateGesturesEnabled: false,
                      tiltGesturesEnabled: false,
                      markers: {
                        Marker(
                          markerId: const MarkerId('event_location_preview'),
                          position: LatLng(
                            selectedLocation!.latitude,
                            selectedLocation!.longitude,
                          ),
                        ),
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLighter,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.my_location_rounded,
                        color: AppColors.primary,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${selectedLocation!.latitude.toStringAsFixed(6)}, '
                          '${selectedLocation!.longitude.toStringAsFixed(6)}',
                          style: AppTextStyles.small.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onPickLocation,
              icon: const Icon(Icons.map_rounded, size: 18),
              label: const Text('Pilih Lokasi di Peta'),
            ),
          ),
        ],
      ),
    );
  }
}

class _DatePickerCard extends StatelessWidget {
  final DateTime date;
  final VoidCallback onTap;

  const _DatePickerCard({required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.greyBorder),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                color: AppColors.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tanggal dan waktu', style: AppTextStyles.caption),
                    const SizedBox(height: 2),
                    Text(
                      '${MaterialLocalizations.of(context).formatFullDate(date)} '
                      '${TimeOfDay.fromDateTime(date).format(context)}',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.keyboard_arrow_down_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldCard extends StatelessWidget {
  final Widget child;

  const _FieldCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.greyBorder),
      ),
      child: child,
    );
  }
}
