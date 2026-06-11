class EventLocationResult {
  final double latitude;
  final double longitude;
  final String? address;
  final String? placeId;

  const EventLocationResult({
    required this.latitude,
    required this.longitude,
    this.address,
    this.placeId,
  });
}
