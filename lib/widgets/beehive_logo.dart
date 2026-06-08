import 'package:flutter/material.dart';
import '../theme.dart';

/// The BeeHive brand mark: a round blue badge with the honeycomb (hive) glyph in
/// honey yellow and a soft blue shadow. Scales cleanly, so the same widget serves
/// the large welcome hero and the small auth headers.
class BeehiveLogo extends StatelessWidget {
  final double size;

  const BeehiveLogo({super.key, this.size = 120});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: BeehiveColors.blue,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: BeehiveColors.blue.withValues(alpha: 0.30),
            blurRadius: size * 0.22,
            offset: Offset(0, size * 0.08),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.hive_rounded,
        size: size * 0.54,
        color: BeehiveColors.yellow,
      ),
    );
  }
}
