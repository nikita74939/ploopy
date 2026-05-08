import 'package:intl/intl.dart';

class DateHelper {
  DateHelper._();

  // ── Nama hari pendek (Senin–Minggu, mulai Senin) ─────────────────────────
  static const List<String> dayNames = [
    'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min',
  ];

  // ── Nama hari panjang ────────────────────────────────────────────────────
  static const List<String> dayNamesFull = [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu',
  ];

  // ── Nama bulan Bahasa Indonesia ──────────────────────────────────────────
  static const List<String> monthNames = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  // ── Greeting berdasarkan jam ─────────────────────────────────────────────
  // Contoh hasil: "Selamat Pagi, Budi 👋"
  static String getGreeting(String name) {
    final hour = DateTime.now().hour;
    final String greeting;

    if (hour >= 4 && hour < 11) {
      greeting = 'Selamat Pagi';
    } else if (hour >= 11 && hour < 15) {
      greeting = 'Selamat Siang';
    } else if (hour >= 15 && hour < 18) {
      greeting = 'Selamat Sore';
    } else {
      greeting = 'Selamat Malam';
    }

    return '$greeting, $name 👋';
  }

  // ── Format tanggal lengkap ───────────────────────────────────────────────
  // Contoh hasil: "Jumat, 9 Mei 2025"
  static String formatFullDate(DateTime date) {
    final dayName = dayNamesFull[_weekdayIndex(date)];
    final month = monthNames[date.month - 1];
    return '$dayName, ${date.day} $month ${date.year}';
  }

  // ── Format bulan + tahun ─────────────────────────────────────────────────
  // Contoh hasil: "Mei 2025"
  static String formatMonthYear(DateTime date) {
    return '${monthNames[date.month - 1]} ${date.year}';
  }

  // ── Format jam HH:mm ─────────────────────────────────────────────────────
  // Contoh hasil: "08:30"
  static String formatTime(DateTime date) {
    final h = date.hour.toString().padLeft(2, '0');
    final m = date.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  // ── Format tanggal pendek ────────────────────────────────────────────────
  // Contoh hasil: "9 Mei"
  static String formatShortDate(DateTime date) {
    return '${date.day} ${monthNames[date.month - 1]}';
  }

  // ── Dapatkan 7 tanggal minggu berjalan (Senin–Minggu) ───────────────────
  static List<DateTime> getCurrentWeekDates() {
    final now = DateTime.now();
    // weekday: 1=Senin, 7=Minggu
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return List.generate(7, (i) {
      final d = monday.add(Duration(days: i));
      return DateTime(d.year, d.month, d.day);
    });
  }

  // ── Dapatkan 7 tanggal minggu dari tanggal tertentu ─────────────────────
  static List<DateTime> getWeekDatesFrom(DateTime date) {
    final monday = date.subtract(Duration(days: date.weekday - 1));
    return List.generate(7, (i) {
      final d = monday.add(Duration(days: i));
      return DateTime(d.year, d.month, d.day);
    });
  }

  // ── Label due date relatif ───────────────────────────────────────────────
  // Contoh hasil: "Kemarin", "Hari ini", "Besok", "+3 hari"
  static String getRelativeDueLabel(DateTime deadline) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final deadlineDay =
        DateTime(deadline.year, deadline.month, deadline.day);
    final diff = deadlineDay.difference(today).inDays;

    if (diff < 0) return 'Kemarin';
    if (diff == 0) return 'Hari ini';
    if (diff == 1) return 'Besok';
    return '+$diff hari';
  }

  // ── Cek apakah tanggal adalah hari ini ───────────────────────────────────
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // ── Cek apakah dua DateTime pada hari yang sama ──────────────────────────
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // ── Waktu dalam detik sejak epoch (untuk sorting) ────────────────────────
  static int toEpochSeconds(DateTime date) {
    return date.millisecondsSinceEpoch ~/ 1000;
  }

  // ── Private: konversi weekday Flutter (1=Sen, 7=Min) ke index list ───────
  static int _weekdayIndex(DateTime date) {
    return date.weekday - 1; // 0=Sen … 6=Min
  }
}