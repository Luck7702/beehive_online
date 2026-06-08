import 'package:flutter/material.dart';
import '../theme.dart';

/// The BeeHive brand mark: a clean round honey badge with the hive glyph and a
/// soft warm shadow. Scales cleanly, so the same widget serves the large welcome
/// hero and the small auth headers.
class BeehiveLogo extends StatelessWidget {
  final double size;

  const BeehiveLogo({super.key, this.size = 120});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: BeehiveColors.honeyGradient,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.40),
            blurRadius: size * 0.28,
            offset: Offset(0, size * 0.12),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.hive_rounded,
        size: size * 0.5,
        color: const Color(0xFF5A3A0E), // dark honey-brown for a bee-like contrast
      ),
    );
  }
}
