import '../../../auth/domain/entities/user_entity.dart';

enum ProfileFriendshipStatus { pending, accepted, blocked }

class ProfileFriendshipEntity {
  final String id;
  final String requesterId;
  final String addresseeId;
  final ProfileFriendshipStatus status;
  final DateTime createdAt;
  final UserEntity? friendUser;

  const ProfileFriendshipEntity({
    required this.id,
    required this.requesterId,
    required this.addresseeId,
    required this.status,
    required this.createdAt,
    this.friendUser,
  });

  bool get isPending => status == ProfileFriendshipStatus.pending;
  bool get isAccepted => status == ProfileFriendshipStatus.accepted;
  bool get isBlocked => status == ProfileFriendshipStatus.blocked;
}
