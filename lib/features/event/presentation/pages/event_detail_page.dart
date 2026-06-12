import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/currency_service.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/event_entity.dart';
import '../bloc/event_bloc.dart';
import 'event_form_page.dart';
import 'event_route_page.dart';

class EventDetailPage extends StatefulWidget {
  final EventEntity event;

  const EventDetailPage({super.key, required this.event});

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  static const _currencyOptions = ['IDR', 'USD', 'EUR'];
  static const double _shakeThreshold = 22;
  static const Duration _shakeCooldown = Duration(milliseconds: 1600);

  String _selectedCurrency = 'IDR';
  Map<String, double> _rates = const {'IDR': 1};
  bool _loadingRates = false;
  late EventEntity _event;
  StreamSubscription<AccelerometerEvent>? _shakeSubscription;
  DateTime _lastShakeAt = DateTime.fromMillisecondsSinceEpoch(0);
  bool _joiningFromShake = false;

  EventEntity get event => _event;

  String? get _currentUserId {
    final state = context.read<AuthBloc>().state;
    return state is Authenticated ? state.user.userId : null;
  }

  @override
  void initState() {
    super.initState();
    _event = widget.event;
    _loadRates();
    _startShakeDetection();
  }

  @override
  void dispose() {
    _shakeSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadRates() async {
    if (event.isFree) return;
    setState(() => _loadingRates = true);
    final result = await CurrencyService.getRates('IDR');
    if (!mounted) return;
    final rates = result['rates'];
    setState(() {
      _rates = rates is Map<String, double> ? rates : const {'IDR': 1};
      _loadingRates = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final accent = _themeAccent(event);
    final userId = _currentUserId;
    final isCreator = userId == event.creatorId;
    final canJoin = !event.isJoinedByMe && !event.isFull && event.isUpcoming;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
          color: AppColors.textMain,
        ),
        title: Text('Detail Event', style: AppTextStyles.title),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 112),
        children: [
          _HeroCard(event: event, accent: accent),
          const SizedBox(height: 14),
          _PriceSection(
            event: event,
            accent: accent,
            selectedCurrency: _selectedCurrency,
            currencies: _currencyOptions,
            loading: _loadingRates,
            priceLabel: _priceLabel(),
            onChanged: (value) {
              if (value == null) return;
              setState(() => _selectedCurrency = value);
            },
          ),
          const SizedBox(height: 14),
          _InfoSection(event: event, accent: accent),
          if (!event.isOnline && event.hasCoordinates) ...[
            const SizedBox(height: 14),
            _EventLocationSection(event: event, accent: accent),
          ],
          if (event.description?.isNotEmpty == true) ...[
            const SizedBox(height: 14),
            _DescriptionSection(description: event.description!),
          ],
          if (event.creatorName != null) ...[
            const SizedBox(height: 14),
            _CreatorSection(event: event, accent: accent),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 10, 20, 18),
        child: Row(
          children: [
            Expanded(
              child: isCreator
                  ? _PrimaryActionButton(
                      label: 'Edit Event',
                      color: accent,
                      icon: Icons.edit_rounded,
                      onPressed: () async {
                        final userId = _currentUserId;
                        if (userId == null) return;
                        final updated = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EventFormPage(
                              currentUserId: userId,
                              event: event,
                            ),
                          ),
                        );
                        if (updated == true && context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                    )
                  : event.isJoinedByMe
                  ? _SecondaryActionButton(
                      label: 'Leave Event',
                      color: AppColors.error,
                      icon: Icons.logout_rounded,
                      onPressed: () {
                        if (userId == null) return;
                        context.read<EventBloc>().add(
                          LeaveEvent(eventId: event.id, userId: userId),
                        );
                        Navigator.pop(context);
                      },
                    )
                  : _PrimaryActionButton(
                      label: canJoin
                          ? 'Join Event'
                          : (!event.isUpcoming ? 'Event Selesai' : 'Penuh'),
                      color: accent,
                      icon: canJoin
                          ? Icons.check_circle_rounded
                          : Icons.lock_rounded,
                      disabled: !canJoin,
                      onPressed: () => _joinEvent(source: _JoinSource.button),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _startShakeDetection() {
    try {
      _shakeSubscription = accelerometerEventStream().listen((event) {
        final now = DateTime.now();
        if (now.difference(_lastShakeAt) < _shakeCooldown) return;

        final acceleration = math.sqrt(
          event.x * event.x + event.y * event.y + event.z * event.z,
        );
        if (acceleration < _shakeThreshold) return;

        _lastShakeAt = now;
        _joinEvent(source: _JoinSource.shake);
      });
    } catch (_) {
      _shakeSubscription = null;
    }
  }

  Future<void> _joinEvent({required _JoinSource source}) async {
    final userId = _currentUserId;
    final canJoin = !event.isJoinedByMe && !event.isFull && event.isUpcoming;

    if (userId == null || userId.isEmpty) {
      if (source == _JoinSource.button && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Silakan login ulang terlebih dahulu.')),
        );
      }
      return;
    }

    if (!canJoin) {
      if (source == _JoinSource.shake && mounted && event.isJoinedByMe) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kamu sudah join event ini.')),
        );
      }
      return;
    }

    if (_joiningFromShake) return;
    setState(() => _joiningFromShake = true);
    try {
      await context.read<EventBloc>().repository.joinEvent(event.id, userId);
      if (!mounted) return;
      setState(() {
        _event = event.copyWith(
          isJoinedByMe: true,
          currentParticipants: event.currentParticipants + 1,
        );
        _joiningFromShake = false;
      });
      context.read<EventBloc>().add(LoadEvents());
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Berhasil join event')));
    } catch (e) {
      if (!mounted) return;
      setState(() => _joiningFromShake = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_cleanError(e))));
    }
  }

  String _cleanError(Object error) {
    final message = error.toString();
    return message.startsWith('Exception: ') ? message.substring(11) : message;
  }

  String _priceLabel() {
    if (event.isFree) return 'FREE';
    final rate = _rates[_selectedCurrency] ?? 1;
    final amount = CurrencyService.convert(amount: event.price, rate: rate);
    final symbol = switch (_selectedCurrency) {
      'USD' => r'$',
      'EUR' => 'EUR ',
      _ => 'Rp',
    };
    final locale = switch (_selectedCurrency) {
      'USD' => 'en_US',
      'EUR' => 'de_DE',
      _ => 'id_ID',
    };
    return NumberFormat.currency(
      locale: locale,
      symbol: symbol,
      decimalDigits: _selectedCurrency == 'IDR' ? 0 : 2,
    ).format(amount);
  }

  Color _themeAccent(EventEntity event) {
    switch (event.icon) {
      case 'workshop':
        return AppColors.tealAccent;
      case 'seminar':
      case 'conference':
      case 'meetup':
        return AppColors.blueAccent;
      case 'sports':
        return AppColors.success;
      case 'music':
        return AppColors.pinkAccent;
      case 'food':
        return AppColors.warning;
      default:
        return AppColors.primary;
    }
  }
}

enum _JoinSource { button, shake }

class _HeroCard extends StatelessWidget {
  final EventEntity event;
  final Color accent;

  const _HeroCard({required this.event, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.primaryBorder),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: accent.withValues(alpha: 0.2)),
                ),
                child: Icon(_iconFromName(event.icon), color: accent, size: 34),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _MiniPill(
                          label: event.isJoinedByMe
                              ? 'JOINED'
                              : event.isFull
                              ? 'FULL'
                              : event.isUpcoming
                              ? 'OPEN'
                              : 'ENDED',
                          color: event.isJoinedByMe
                              ? AppColors.blueAccent
                              : event.isFull
                              ? AppColors.error
                              : event.isUpcoming
                              ? AppColors.success
                              : AppColors.textMuted,
                        ),
                        _MiniPill(
                          label: event.isOnline ? 'ONLINE' : 'ONSITE',
                          color: accent,
                        ),
                      ],
                    ),
                    const SizedBox(height: 9),
                    Text(
                      event.name,
                      style: AppTextStyles.heading.copyWith(fontSize: 22),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _DetailLine(
            icon: Icons.calendar_today_rounded,
            label: DateTimeUtils.formatDateTime(event.eventDate),
          ),
          const SizedBox(height: 9),
          _DetailLine(
            icon: event.isOnline
                ? Icons.videocam_rounded
                : Icons.location_on_rounded,
            label: event.isOnline ? 'Online' : event.displayLocation,
          ),
        ],
      ),
    );
  }

  IconData _iconFromName(String? iconName) {
    switch (iconName) {
      case 'conference':
      case 'meetup':
        return Icons.groups_rounded;
      case 'workshop':
        return Icons.build_rounded;
      case 'seminar':
        return Icons.school_rounded;
      case 'sports':
        return Icons.sports_rounded;
      case 'music':
        return Icons.music_note_rounded;
      case 'food':
        return Icons.restaurant_rounded;
      default:
        return Icons.event_rounded;
    }
  }
}

class _PriceSection extends StatelessWidget {
  final EventEntity event;
  final Color accent;
  final String selectedCurrency;
  final List<String> currencies;
  final bool loading;
  final String priceLabel;
  final ValueChanged<String?> onChanged;

  const _PriceSection({
    required this.event,
    required this.accent,
    required this.selectedCurrency,
    required this.currencies,
    required this.loading,
    required this.priceLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Harga', style: AppTextStyles.caption),
                const SizedBox(height: 4),
                Text(
                  loading ? 'Memuat kurs...' : priceLabel,
                  style: AppTextStyles.heading.copyWith(
                    color: event.isFree ? AppColors.success : accent,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
          ),
          if (!event.isFree)
            Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.primaryLighter,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.greyBorder),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedCurrency,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  style: AppTextStyles.buttonSecondary.copyWith(color: accent),
                  items: currencies
                      .map(
                        (currency) => DropdownMenuItem(
                          value: currency,
                          child: Text(currency),
                        ),
                      )
                      .toList(),
                  onChanged: onChanged,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final EventEntity event;
  final Color accent;

  const _InfoSection({required this.event, required this.accent});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Row(
        children: [
          Expanded(
            child: _InfoMetric(
              icon: Icons.people_alt_rounded,
              label: 'Peserta',
              value: event.maxParticipants == null
                  ? '${event.currentParticipants}'
                  : '${event.currentParticipants}/${event.maxParticipants}',
              color: event.isFull ? AppColors.error : accent,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _InfoMetric(
              icon: Icons.access_time_rounded,
              label: 'Status',
              value: event.isUpcoming ? 'Akan datang' : 'Selesai',
              color: event.isUpcoming ? AppColors.success : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _DescriptionSection extends StatelessWidget {
  final String description;

  const _DescriptionSection({required this.description});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Deskripsi', style: AppTextStyles.title),
          const SizedBox(height: 8),
          Text(
            description,
            style: AppTextStyles.bodySmall.copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _EventLocationSection extends StatelessWidget {
  final EventEntity event;
  final Color accent;

  const _EventLocationSection({required this.event, required this.accent});

  @override
  Widget build(BuildContext context) {
    final point = LatLng(event.latitude!, event.longitude!);
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on_rounded, color: accent),
              const SizedBox(width: 8),
              Text('Lokasi Event', style: AppTextStyles.title),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 170,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(target: point, zoom: 15),
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
                scrollGesturesEnabled: false,
                rotateGesturesEnabled: false,
                tiltGesturesEnabled: false,
                markers: {
                  Marker(
                    markerId: const MarkerId('event_location'),
                    position: point,
                    infoWindow: InfoWindow(title: event.name),
                  ),
                },
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(event.displayLocation, style: AppTextStyles.bodySmall),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EventRoutePage(event: event),
                    ),
                  ),
                  icon: const Icon(Icons.route_rounded, size: 18),
                  label: const Text('Lihat Rute'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      await DependencyInjection.eventLocationService
                          .openGoogleMapsNavigation(point);
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                  },
                  icon: const Icon(Icons.navigation_rounded, size: 18),
                  label: Text(
                    'Mulai Navigasi',
                    style: AppTextStyles.buttonPrimary.copyWith(fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CreatorSection extends StatelessWidget {
  final EventEntity event;
  final Color accent;

  const _CreatorSection({required this.event, required this.accent});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Row(
        children: [
          _EventCreatorAvatar(
            name: event.creatorName!,
            photoUrl: event.creatorPhoto,
            color: accent,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Dibuat oleh', style: AppTextStyles.caption),
                const SizedBox(height: 2),
                Text(
                  event.creatorName!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.title,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EventCreatorAvatar extends StatelessWidget {
  final String name;
  final String? photoUrl;
  final Color color;

  const _EventCreatorAvatar({
    required this.name,
    required this.photoUrl,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final initial = name.isEmpty ? '?' : name[0].toUpperCase();

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
      ),
      alignment: Alignment.center,
      child: photoUrl != null && photoUrl!.trim().isNotEmpty
          ? ClipOval(
              child: Image.network(
                photoUrl!,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    _EventCreatorInitial(initial: initial, color: color),
              ),
            )
          : _EventCreatorInitial(initial: initial, color: color),
    );
  }
}

class _EventCreatorInitial extends StatelessWidget {
  final String initial;
  final Color color;

  const _EventCreatorInitial({required this.initial, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      initial,
      style: AppTextStyles.title.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: color,
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;

  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.greyBorder),
      ),
      child: child,
    );
  }
}

class _InfoMetric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 78),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 19),
          const SizedBox(height: 8),
          Text(value, style: AppTextStyles.title.copyWith(color: color)),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DetailLine({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodySmall,
          ),
        ),
      ],
    );
  }
}

class _MiniPill extends StatelessWidget {
  final String label;
  final Color color;

  const _MiniPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: AppTextStyles.small.copyWith(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final bool disabled;
  final VoidCallback onPressed;

  const _PrimaryActionButton({
    required this.label,
    required this.color,
    required this.icon,
    required this.onPressed,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton.icon(
        onPressed: disabled ? null : onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label, style: AppTextStyles.buttonPrimary),
        style: ElevatedButton.styleFrom(
          backgroundColor: disabled ? AppColors.textMuted : color,
          foregroundColor: AppColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

class _SecondaryActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onPressed;

  const _SecondaryActionButton({
    required this.label,
    required this.color,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(
          label,
          style: AppTextStyles.buttonSecondary.copyWith(color: color),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
