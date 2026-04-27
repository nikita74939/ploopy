class DateHelper {
  static const List<String> dayNames = [
    'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'
  ];

  static const List<String> monthNames = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  static String formatFullDate(DateTime date) {
    return '${dayNames[date.weekday - 1]}, ${date.day} ${monthNames[date.month - 1]} ${date.year}';
  }

  static String getGreeting(String name) {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Pagi, $name';
    if (hour < 15) return 'Siang, $name';
    if (hour < 18) return 'Sore, $name';
    return 'Malam, $name';
  }

  static List<DateTime> getCurrentWeekDates() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return List.generate(7, (i) => monday.add(Duration(days: i)));
  }
}