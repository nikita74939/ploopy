class EventEntity {
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

  const EventEntity({
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
    required this.currentParticipants,
    this.description,
    required this.price,
    required this.isJoinedByMe,
    required this.createdAt,
    this.creatorName,
    this.creatorPhoto,
  });

  bool get isFree => price == 0;
  bool get isFull =>
      maxParticipants != null && currentParticipants >= maxParticipants!;
  bool get isUpcoming => eventDate.isAfter(DateTime.now());
  bool get hasCoordinates => latitude != null && longitude != null;
  String get displayLocation {
    final value = address ?? location;
    return value == null || value.trim().isEmpty ? 'TBD' : value.trim();
  }
}
