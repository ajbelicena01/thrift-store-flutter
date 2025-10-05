// lib/widgets/info_chip.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const InfoChip({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Color(0xFFf5f5f5).withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Color(0xFF0b6477)),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.archivo(fontSize: 12, color: Color(0xFF0b6477)),
          ),
        ],
      ),
    );
  }
}
