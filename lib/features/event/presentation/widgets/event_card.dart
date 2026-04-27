import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EventCard extends StatelessWidget {
  final Map<String, dynamic> event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final coverColor = event['coverColor'] as Color;
    final joined = event['joined'] as bool;
    final hasDistance = event['distance'] != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCover(coverColor),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCategoryBadge(coverColor),
                const SizedBox(height: 8),
                Text(
                  event['title'] as String,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                _buildInfoRow(
                  Icons.calendar_today_rounded,
                  '${event['date']} · ${event['time']}',
                ),
                const SizedBox(height: 6),
                _buildInfoRow(
                  Icons.location_on_rounded,
                  hasDistance
                      ? '${event['location']} · ${event['distance']}'
                      : event['location'] as String,
                ),
                const SizedBox(height: 14),
                _buildFooter(coverColor, joined),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCover(Color color) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.8), color],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      alignment: Alignment.center,
      child: Text(
        event['emoji'] as String,
        style: const TextStyle(fontSize: 44),
      ),
    );
  }

  Widget _buildCategoryBadge(Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        event['category'] as String,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 13, color: Colors.grey.shade500),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(Color color, bool joined) {
    final participants = event['participants'] as int;
    final max = event['maxParticipants'] as int;
    final percentage = participants / max;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('👥', style: GoogleFonts.poppins(fontSize: 12)),
                  const SizedBox(width: 5),
                  Text(
                    '$participants / $max peserta',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: percentage,
                  minHeight: 4,
                  backgroundColor: Colors.grey.shade100,
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _buildJoinButton(color, joined),
      ],
    );
  }

  Widget _buildJoinButton(Color color, bool joined) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      decoration: BoxDecoration(
        color: joined ? Colors.grey.shade100 : color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            joined ? Icons.check_rounded : Icons.add_rounded,
            size: 14,
            color: joined ? Colors.grey.shade600 : Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            joined ? 'Joined' : 'Join',
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: joined ? Colors.grey.shade600 : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}