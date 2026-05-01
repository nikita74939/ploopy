import 'package:shared_preferences/shared_preferences.dart';

class ProfilePrefsService {
  static const _keyName        = 'profile_name';
  static const _keyBio         = 'profile_bio';
  static const _keyAvatarChar  = 'profile_avatar_char';
  static const _keyAvatarColor = 'profile_avatar_color';
  static const _keyJoinYear    = 'profile_join_year';
  static const _keyTotalFriends     = 'profile_total_friends';
  static const _keyTotalActivities  = 'profile_total_activities';

  // ── SAVE ──────────────────────────────────────────

  static Future<void> saveName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyName, name);
  }

  static Future<void> saveBio(String bio) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyBio, bio);
  }

  static Future<void> saveAvatar({
    required String char,
    required int colorValue,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAvatarChar, char);
    await prefs.setInt(_keyAvatarColor, colorValue);
  }

  static Future<void> saveStats({
    required int totalFriends,
    required int totalActivities,
    required int joinYear,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyTotalFriends, totalFriends);
    await prefs.setInt(_keyTotalActivities, totalActivities);
    await prefs.setInt(_keyJoinYear, joinYear);
  }

  // ── GET ───────────────────────────────────────────

  static Future<String> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyName) ?? 'Pengguna';
  }

  static Future<String> getBio() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyBio) ?? '';
  }

  static Future<String> getAvatarChar() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAvatarChar) ?? 'U';
  }

  static Future<int> getAvatarColor() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyAvatarColor) ?? 0xFFFF8C42; // default orange
  }

  static Future<int> getTotalFriends() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyTotalFriends) ?? 0;
  }

  static Future<int> getTotalActivities() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyTotalActivities) ?? 0;
  }

  static Future<int> getJoinYear() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyJoinYear) ?? DateTime.now().year;
  }

  // ── Ambil semua sekaligus (buat profile_page.dart) ─
  static Future<Map<String, dynamic>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name':             prefs.getString(_keyName) ?? 'Pengguna',
      'bio':              prefs.getString(_keyBio) ?? '',
      'avatarChar':       prefs.getString(_keyAvatarChar) ?? 'U',
      'avatarColor':      prefs.getInt(_keyAvatarColor) ?? 0xFFFF8C42,
      'totalFriends':     prefs.getInt(_keyTotalFriends) ?? 0,
      'totalActivities':  prefs.getInt(_keyTotalActivities) ?? 0,
      'joinYear':         prefs.getInt(_keyJoinYear) ?? DateTime.now().year,
    };
  }
}