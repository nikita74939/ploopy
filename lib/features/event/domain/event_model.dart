// event/domain/event_model.dart
class Event {
  final String id;
  final String title;
  final String description;
  final String organizerId;
  final String organizerName;
  final String? location;
  final double? latitude;
  final double? longitude;
  final DateTime dateTime;
  final int maxParticipants;
  final int currentParticipants;
  final List<String> participantIds;
  final String? imageUrl;
  final bool isJoined;
  final DateTime createdAt;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.organizerId,
    required this.organizerName,
    this.location,
    this.latitude,
    this.longitude,
    required this.dateTime,
    required this.maxParticipants,
    this.currentParticipants = 0,
    this.participantIds = const [],
    this.imageUrl,
    this.isJoined = false,
    required this.createdAt,
  });

  bool get isFull => currentParticipants >= maxParticipants;
  bool get isUpcoming => dateTime.isAfter(DateTime.now());
  bool get isPast => dateTime.isBefore(DateTime.now());
  bool get hasLocation => latitude != null && longitude != null;

  int get spotsLeft => maxParticipants - currentParticipants;

  Event copyWith({
    String? id,
    String? title,
    String? description,
    String? organizerId,
    String? organizerName,
    String? location,
    double? latitude,
    double? longitude,
    DateTime? dateTime,
    int? maxParticipants,
    int? currentParticipants,
    List<String>? participantIds,
    String? imageUrl,
    bool? isJoined,
    DateTime? createdAt,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      organizerId: organizerId ?? this.organizerId,
      organizerName: organizerName ?? this.organizerName,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      dateTime: dateTime ?? this.dateTime,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      currentParticipants: currentParticipants ?? this.currentParticipants,
      participantIds: participantIds ?? this.participantIds,
      imageUrl: imageUrl ?? this.imageUrl,
      isJoined: isJoined ?? this.isJoined,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'organizerId': organizerId,
        'organizerName': organizerName,
        'location': location,
        'latitude': latitude,
        'longitude': longitude,
        'dateTime': dateTime.toIso8601String(),
        'maxParticipants': maxParticipants,
        'currentParticipants': currentParticipants,
        'participantIds': participantIds,
        'imageUrl': imageUrl,
        'isJoined': isJoined,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      organizerId: json['organizerId'] as String,
      organizerName: json['organizerName'] as String,
      location: json['location'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      dateTime: DateTime.parse(json['dateTime'] as String),
      maxParticipants: json['maxParticipants'] as int,
      currentParticipants: json['currentParticipants'] as int? ?? 0,
      participantIds: (json['participantIds'] as List?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      imageUrl: json['imageUrl'] as String?,
      isJoined: json['isJoined'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}