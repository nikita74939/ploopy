class FriendshipEntity {
  final int id;
  final String requesterId;
  final String addresseeId;
  final String status; // pending | accepted | rejected
  final DateTime createdAt;

  const FriendshipEntity({
    required this.id,
    required this.requesterId,
    required this.addresseeId,
    required this.status,
    required this.createdAt,
  });
}
