import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../../../../core/config/api_config.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../activity/domain/entities/activity_entity.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';

class PublicProfilePage extends StatefulWidget {
  final String userId;

  const PublicProfilePage({super.key, required this.userId});

  @override
  State<PublicProfilePage> createState() => _PublicProfilePageState();
}

class _PublicProfilePageState extends State<PublicProfilePage> {
  static const _secureStorage = FlutterSecureStorage();

  late Future<_PublicProfileData> _future;
  _FriendshipInfo? _friendship;
  String? _currentUserId;
  bool _isActionLoading = false;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    _currentUserId = authState is Authenticated ? authState.user.userId : null;
    _future = _load();
  }

  Future<_PublicProfileData> _load() async {
    final user = await DependencyInjection.profileRepository.getUserById(
      widget.userId,
    );
    final activities = await DependencyInjection.activityRepository
        .getActivitiesByUser(widget.userId);
    final friendship = await _loadFriendship();
    if (user == null) throw Exception('User tidak ditemukan');
    _friendship = friendship;
    return _PublicProfileData(user: user, activities: activities);
  }

  Future<_FriendshipInfo?> _loadFriendship() async {
    final currentUserId = _currentUserId;
    if (currentUserId == null || currentUserId == widget.userId) return null;

    final response = await http.get(
      _uri('/api/friends'),
      headers: await _jsonHeaders(),
    );
    final data = _decode(response);
    final friendships = (data['friendships'] as List?) ?? [];

    for (final item in friendships) {
      final row = item as Map<String, dynamic>;
      final requesterId = row['requester_id']?.toString();
      final addresseeId = row['addressee_id']?.toString();
      final isCurrentPair =
          (requesterId == currentUserId && addresseeId == widget.userId) ||
          (requesterId == widget.userId && addresseeId == currentUserId);
      if (isCurrentPair) return _FriendshipInfo.fromJson(row);
    }
    return null;
  }

  Future<void> _sendFriendRequest() async {
    if (_currentUserId == null || _isActionLoading) return;
    setState(() => _isActionLoading = true);
    try {
      final response = await http.post(
        _uri('/api/friends'),
        headers: await _jsonHeaders(),
        body: jsonEncode({'addresseeId': widget.userId}),
      );
      final data = _decode(response);
      final friendship = data['friendship'] as Map<String, dynamic>?;
      if (!mounted) return;
      setState(() {
        _friendship = friendship == null
            ? null
            : _FriendshipInfo.fromJson(friendship);
      });
      _refreshMyProfileStats();
      _showSnackBar('Permintaan pertemanan dikirim.');
    } catch (e) {
      if (mounted) _showSnackBar(_cleanError(e), isError: true);
    } finally {
      if (mounted) setState(() => _isActionLoading = false);
    }
  }

  Future<void> _confirmRemoveFriend() async {
    if (_friendship == null || _isActionLoading) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Hapus pertemanan?',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Kamu dan pengguna ini tidak akan berteman lagi.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed == true) await _removeFriend();
  }

  Future<void> _removeFriend() async {
    final friendship = _friendship;
    if (friendship == null) return;
    setState(() => _isActionLoading = true);
    try {
      final response = await http.delete(
        _uri('/api/friends/${friendship.id}'),
        headers: await _jsonHeaders(),
      );
      _decode(response);
      if (!mounted) return;
      setState(() => _friendship = null);
      _refreshMyProfileStats();
      _showSnackBar('Pertemanan dihapus.');
    } catch (e) {
      if (mounted) _showSnackBar(_cleanError(e), isError: true);
    } finally {
      if (mounted) setState(() => _isActionLoading = false);
    }
  }

  Uri _uri(String path) => Uri.parse('${ApiConfig.baseUrl}$path');

  Future<Map<String, String>> _jsonHeaders() async {
    final token = await _secureStorage.read(key: 'auth_token');
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Map<String, dynamic> _decode(http.Response response) {
    final body = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        body['message']?.toString() ?? 'Request gagal. Coba lagi.',
      );
    }

    return body;
  }

  String _cleanError(Object e) {
    final msg = e.toString();
    return msg.startsWith('Exception: ') ? msg.substring(11) : msg;
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : null,
      ),
    );
  }

  void _refreshMyProfileStats() {
    final userId = _currentUserId;
    if (userId == null) return;
    context.read<ProfileBloc>().add(
      LoadProfile(userId: userId, forceRefresh: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Profil')),
      body: FutureBuilder<_PublicProfileData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Text(
                'Gagal memuat profil',
                style: GoogleFonts.poppins(color: AppColors.textSecondary),
              ),
            );
          }
          final data = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              _ProfileHeader(
                user: data.user,
                isOwnProfile: _currentUserId == widget.userId,
                friendship: _friendship,
                isLoading: _isActionLoading,
                onAddFriend: _sendFriendRequest,
                onRemoveFriend: _confirmRemoveFriend,
              ),
              const SizedBox(height: 22),
              Text(
                'Activity',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 10),
              if (data.activities.isEmpty)
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.greyBorder),
                  ),
                  child: Text(
                    'Belum ada activity.',
                    style: GoogleFonts.poppins(color: AppColors.textMuted),
                  ),
                )
              else
                ...data.activities.map(_SimpleActivityCard.new),
            ],
          );
        },
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final UserEntity user;
  final bool isOwnProfile;
  final _FriendshipInfo? friendship;
  final bool isLoading;
  final VoidCallback onAddFriend;
  final VoidCallback onRemoveFriend;

  const _ProfileHeader({
    required this.user,
    required this.isOwnProfile,
    required this.friendship,
    required this.isLoading,
    required this.onAddFriend,
    required this.onRemoveFriend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.greyBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: AppColors.primaryLighter,
            backgroundImage:
                user.avatarUrl != null && user.avatarUrl!.trim().isNotEmpty
                ? NetworkImage(user.avatarUrl!)
                : null,
            child: user.avatarUrl == null || user.avatarUrl!.trim().isEmpty
                ? Text(
                    user.name.isEmpty ? '?' : user.name[0].toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMain,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.bio?.trim().isNotEmpty == true
                      ? user.bio!
                      : 'Belum ada bio.',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          if (!isOwnProfile) ...[
            const SizedBox(width: 12),
            _FriendButton(
              friendship: friendship,
              isLoading: isLoading,
              onAddFriend: onAddFriend,
              onRemoveFriend: onRemoveFriend,
            ),
          ],
        ],
      ),
    );
  }
}

class _FriendButton extends StatelessWidget {
  final _FriendshipInfo? friendship;
  final bool isLoading;
  final VoidCallback onAddFriend;
  final VoidCallback onRemoveFriend;

  const _FriendButton({
    required this.friendship,
    required this.isLoading,
    required this.onAddFriend,
    required this.onRemoveFriend,
  });

  @override
  Widget build(BuildContext context) {
    final status = friendship?.status;
    final isPending = status == 'pending';
    final isFriend = status == 'accepted';
    final label = isFriend ? 'Friend' : 'Add Friend';
    final enabled = !isLoading && !isPending;
    final backgroundColor = isPending
        ? Colors.grey.shade300
        : isFriend
        ? AppColors.primaryLighter
        : AppColors.primary;
    final foregroundColor = isPending
        ? Colors.grey.shade600
        : isFriend
        ? AppColors.primary
        : AppColors.white;

    return SizedBox(
      height: 38,
      child: ElevatedButton(
        onPressed: enabled
            ? isFriend
                  ? onRemoveFriend
                  : onAddFriend
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          disabledBackgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          disabledForegroundColor: foregroundColor,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isFriend
                ? BorderSide(color: AppColors.primary.withValues(alpha: 0.35))
                : BorderSide.none,
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: foregroundColor,
                ),
              )
            : Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}

class _SimpleActivityCard extends StatelessWidget {
  final ActivityEntity activity;

  const _SimpleActivityCard(this.activity);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.greyBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            activity.text,
            style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textMain),
          ),
          if (activity.imageUrls.isNotEmpty) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                activity.imageUrls.first,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.favorite_rounded, size: 16, color: AppColors.error),
              const SizedBox(width: 4),
              Text(
                '${activity.likeCount}',
                style: GoogleFonts.poppins(fontSize: 11),
              ),
              const SizedBox(width: 14),
              Icon(
                Icons.mode_comment_rounded,
                size: 16,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 4),
              Text(
                '${activity.commentCount}',
                style: GoogleFonts.poppins(fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PublicProfileData {
  final UserEntity user;
  final List<ActivityEntity> activities;

  const _PublicProfileData({required this.user, required this.activities});
}

class _FriendshipInfo {
  final String id;
  final String requesterId;
  final String addresseeId;
  final String status;

  const _FriendshipInfo({
    required this.id,
    required this.requesterId,
    required this.addresseeId,
    required this.status,
  });

  factory _FriendshipInfo.fromJson(Map<String, dynamic> json) {
    return _FriendshipInfo(
      id: json['id'].toString(),
      requesterId: json['requester_id'].toString(),
      addresseeId: json['addressee_id'].toString(),
      status: json['status']?.toString() ?? 'pending',
    );
  }
}
