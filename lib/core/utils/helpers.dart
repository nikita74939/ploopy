import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class Helpers {
  static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  static void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  static String getRandomQuote() {
    final quotes = [
      "The secret of getting ahead is getting started. - Mark Twain",
      "It always seems impossible until it's done. - Nelson Mandela",
      "Don't watch the clock; do what it does. Keep going. - Sam Levenson",
      "Success is not final, failure is not fatal: it is the courage to continue that counts. - Winston Churchill",
      "The only way to do great work is to love what you do. - Steve Jobs",
    ];
    return quotes[DateTime.now().second % quotes.length];
  }

  static Color getColorFromString(String colorString) {
    switch (colorString.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.yellow;
      case 'purple':
        return Colors.purple;
      case 'orange':
        return Colors.orange;
      case 'pink':
        return Colors.pink;
      case 'teal':
        return Colors.teal;
      case 'indigo':
        return Colors.indigo;
      default:
        return AppColors.primary;
    }
  }

  static IconData getIconFromString(String iconName) {
    final icons = {
      'event': Icons.event,
      'schedule': Icons.schedule,
      'task': Icons.assignment,
      'meeting': Icons.groups,
      'class': Icons.school,
      'exam': Icons.quiz,
      'personal': Icons.person,
      'study': Icons.book,
      'sport': Icons.sports,
      'music': Icons.music_note,
      'art': Icons.palette,
      'code': Icons.code,
    };
    return icons[iconName.toLowerCase()] ?? Icons.event;
  }
}