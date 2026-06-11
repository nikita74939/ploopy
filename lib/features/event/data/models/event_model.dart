import '../../domain/entities/event_entity.dart';

class EventModel {
  final String id;
  final String creatorId;
  final String name;
  final String? icon;
  final String color;
  final DateTime eventDate;
  final String? location;
  final double? latitude;
  final double? longitude;
  final String? placeId;
  final String? address;
  final bool isOnline;
  final int? maxParticipants;
  final int currentParticipants;
  final String? description;
  final double price;
  final bool isJoinedByMe;
  final DateTime createdAt;

  // Joined from profiles
  final String? creatorName;
  final String? creatorPhoto;

  const EventModel({
    required this.id,
    required this.creatorId,
    required this.name,
    this.icon,
    required this.color,
    required this.eventDate,
    this.location,
    this.latitude,
    this.longitude,
    this.placeId,
    this.address,
    required this.isOnline,
    this.maxParticipants,
    this.currentParticipants = 0,
    this.description,
    required this.price,
    this.isJoinedByMe = false,
    required this.createdAt,
    this.creatorName,
    this.creatorPhoto,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    final participants = (json['event_participants'] as List?) ?? const [];
    final creator =
        json['creator'] as Map<String, dynamic>? ??
        json['profiles'] as Map<String, dynamic>?;
    final createdAt = _parseDate(json['created_at']) ?? DateTime.now();
    return EventModel(
      id: json['id']?.toString() ?? '',
      creatorId: json['creator_id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Event',
      icon: json['icon'] as String?,
      color: json['color']?.toString().isNotEmpty == true
          ? json['color'].toString()
          : '#FF7600',
      eventDate: _parseDate(json['event_date']) ?? createdAt,
      location: json['location'] as String?,
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      placeId: json['place_id'] as String?,
      address: json['address'] as String?,
      isOnline: json['is_online'] as bool? ?? false,
      maxParticipants: json['max_participants'] as int?,
      currentParticipants:
          (json['current_participants'] as num?)?.toInt() ??
          participants.length,
      description: json['description'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      isJoinedByMe: json['is_joined_by_me'] as bool? ?? false,
      createdAt: createdAt,
      creatorName: creator?['name'] as String?,
      creatorPhoto: creator?['avatar_url'] as String?,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    final raw = value?.toString();
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  factory EventModel.fromEntity(EventEntity entity) {
    return EventModel(
      id: entity.id,
      creatorId: entity.creatorId,
      name: entity.name,
      icon: entity.icon,
      color: entity.color,
      eventDate: entity.eventDate,
      location: entity.location,
      latitude: entity.latitude,
      longitude: entity.longitude,
      placeId: entity.placeId,
      address: entity.address,
      isOnline: entity.isOnline,
      maxParticipants: entity.maxParticipants,
      currentParticipants: entity.currentParticipants,
      description: entity.description,
      price: entity.price,
      isJoinedByMe: entity.isJoinedByMe,
      createdAt: entity.createdAt,
      creatorName: entity.creatorName,
      creatorPhoto: entity.creatorPhoto,
    );
  }

  Map<String, dynamic> toApiJson() => {
    'name': name,
    if (icon != null) 'icon': icon,
    'color': color,
    'eventDate': eventDate.toIso8601String(),
    if (location != null) 'location': location,
    'latitude': latitude,
    'longitude': longitude,
    if (placeId != null) 'placeId': placeId,
    if (address != null) 'address': address,
    'isOnline': isOnline,
    if (maxParticipants != null) 'maxParticipants': maxParticipants,
    if (description != null) 'description': description,
    'price': price,
  };

  Map<String, dynamic> toInsertJson() => {
    'creator_id': creatorId,
    ...toApiJson(),
  };

  Map<String, dynamic> toUpdateJson() => {
    'name': name,
    if (icon != null) 'icon': icon,
    'color': color,
    'event_date': eventDate.toIso8601String(),
    if (location != null) 'location': location,
    'latitude': latitude,
    'longitude': longitude,
    if (placeId != null) 'place_id': placeId,
    if (address != null) 'address': address,
    'is_online': isOnline,
    if (maxParticipants != null) 'max_participants': maxParticipants,
    if (description != null) 'description': description,
    'price': price,
  };

  EventEntity toEntity() => EventEntity(
    id: id,
    creatorId: creatorId,
    name: name,
    icon: icon,
    color: color,
    eventDate: eventDate,
    location: location,
    latitude: latitude,
    longitude: longitude,
    placeId: placeId,
    address: address,
    isOnline: isOnline,
    maxParticipants: maxParticipants,
    currentParticipants: currentParticipants,
    description: description,
    price: price,
    isJoinedByMe: isJoinedByMe,
    createdAt: createdAt,
    creatorName: creatorName,
    creatorPhoto: creatorPhoto,
  );

  EventModel copyWith({bool? isJoinedByMe, int? currentParticipants}) =>
      EventModel(
        id: id,
        creatorId: creatorId,
        name: name,
        icon: icon,
        color: color,
        eventDate: eventDate,
        location: location,
        latitude: latitude,
        longitude: longitude,
        placeId: placeId,
        address: address,
        isOnline: isOnline,
        maxParticipants: maxParticipants,
        currentParticipants: currentParticipants ?? this.currentParticipants,
        description: description,
        price: price,
        isJoinedByMe: isJoinedByMe ?? this.isJoinedByMe,
        createdAt: createdAt,
        creatorName: creatorName,
        creatorPhoto: creatorPhoto,
      );

  bool get isFree => price == 0;
  bool get isFull =>
      maxParticipants != null && currentParticipants >= maxParticipants!;
  bool get isUpcoming => eventDate.isAfter(DateTime.now());
  bool get hasCoordinates => latitude != null && longitude != null;
}
