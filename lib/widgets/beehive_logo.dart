import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';

/// The BeeHive brand mark: a honeycomb hexagon in warm honey with a soft drop
/// shadow, a glassy top highlight, and the hive glyph in dark amber. Scales
/// cleanly, so the same widget serves the large welcome hero and the small auth
/// headers.
class BeehiveLogo extends StatelessWidget {
  final double size;

  const BeehiveLogo({super.key, this.size = 120});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _HexBadgePainter(),
        child: Center(
          child: Icon(
            Icons.hive_rounded,
            size: size * 0.46,
            color: const Color(0xFF5A3A0E), // dark honey-brown for a bee-like contrast
          ),
        ),
      ),
    );
  }
}

class _HexBadgePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.47;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final path = _hexagonPath(center, radius);

    // Warm drop shadow that follows the hexagon outline.
    canvas.drawShadow(path, const Color(0xFFB45309), size.width * 0.06, true);

    // Honey gradient fill.
    canvas.drawPath(path, Paint()..shader = BeehiveColors.honeyGradient.createShader(rect));

    // Glassy highlight across the top for a little depth.
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.center,
          colors: [Colors.white.withValues(alpha: 0.28), Colors.white.withValues(alpha: 0.0)],
        ).createShader(rect),
    );

    // Thin amber rim for definition.
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.022
        ..color = const Color(0xFFD97706).withValues(alpha: 0.65),
    );
  }

  // Flat-top regular hexagon (a honeycomb cell) centred on [c].
  Path _hexagonPath(Offset c, double r) {
    final path = Path();
    for (var i = 0; i < 6; i++) {
      final angle = math.pi / 180 * (60 * i);
      final point = Offset(c.dx + r * math.cos(angle), c.dy + r * math.sin(angle));
      i == 0 ? path.moveTo(point.dx, point.dy) : path.lineTo(point.dx, point.dy);
    }
    return path..close();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
