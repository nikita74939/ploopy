import '../../../auth/data/models/user_model.dart';

/// Status pertemanan yang valid di Supabase
enum FriendshipStatus { pending, accepted, blocked }

extension FriendshipStatusExt on FriendshipStatus {
  String get value {
    switch (this) {
      case FriendshipStatus.pending:
        return 'pending';
      case FriendshipStatus.accepted:
        return 'accepted';
      case FriendshipStatus.blocked:
        return 'blocked';
    }
  }

  static FriendshipStatus fromString(String s) {
    switch (s) {
      case 'accepted':
        return FriendshipStatus.accepted;
      case 'blocked':
        return FriendshipStatus.blocked;
      default:
        return FriendshipStatus.pending;
    }
  }
}

/// Merepresentasikan baris dari tabel `friendships` di Supabase.
///
/// Schema Supabase:
///   id            uuid PK
///   requester_id  uuid FK → users
///   addressee_id  uuid FK → users
///   status        text CHECK (pending | accepted | blocked) default 'pending'
///   created_at    timestamptz default now()
class FriendshipModel {
  final String id;
  final String requesterId;
  final String addresseeId;
  final FriendshipStatus status;
  final DateTime createdAt;

  /// User detail dari join (requester atau addressee, tergantung konteks)
  final UserModel? friendUser;

  const FriendshipModel({
    required this.id,
    required this.requesterId,
    required this.addresseeId,
    required this.status,
    required this.createdAt,
    this.friendUser,
  });

  factory FriendshipModel.fromJson(
    Map<String, dynamic> json, {
    String? currentUserId,
  }) {
    UserModel? friendUser;

    // Join dari tabel users untuk requester atau addressee
    if (currentUserId != null) {
      final isRequester = json['requester_id'] == currentUserId;
      final userJson = isRequester
          ? json['addressee'] as Map<String, dynamic>?
          : json['requester'] as Map<String, dynamic>?;
      if (userJson != null) {
        friendUser = UserModel.fromSupabase(userJson);
      }
    }

    return FriendshipModel(
      id: json['id'] as String,
      requesterId: json['requester_id'] as String,
      addresseeId: json['addressee_id'] as String,
      status: FriendshipStatusExt.fromString(json['status'] as String? ?? 'pending'),
      createdAt: DateTime.parse(json['created_at'] as String),
      friendUser: friendUser,
    );
  }

  /// Untuk insert pertemanan baru (status default = pending)
  Map<String, dynamic> toInsertJson() => {
        'requester_id': requesterId,
        'addressee_id': addresseeId,
        'status': 'pending',
      };

  /// Untuk update status pertemanan
  Map<String, dynamic> toUpdateJson() => {
        'status': status.value,
      };

  bool get isPending => status == FriendshipStatus.pending;
  bool get isAccepted => status == FriendshipStatus.accepted;
  bool get isBlocked => status == FriendshipStatus.blocked;
}