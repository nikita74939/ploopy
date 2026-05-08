import '../../domain/entities/friendship_entity.dart';

class FriendshipModel {
  final int id;
  final String requesterId;
  final String addresseeId;
  final String status;
  final DateTime createdAt;

  const FriendshipModel({
    required this.id,
    required this.requesterId,
    required this.addresseeId,
    required this.status,
    required this.createdAt,
  });

  FriendshipEntity toEntity() => FriendshipEntity(
    id: id,
    requesterId: requesterId,
    addresseeId: addresseeId,
    status: status,
    createdAt: createdAt,
  );

  factory FriendshipModel.fromJson(Map<String, dynamic> j) => FriendshipModel(
    id: j['id'],
    requesterId: j['requester_id'],
    addresseeId: j['addressee_id'],
    status: j['status'],
    createdAt: DateTime.parse(j['created_at']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'requester_id': requesterId,
    'addressee_id': addresseeId,
    'status': status,
    'created_at': createdAt.toIso8601String(),
  };
}
