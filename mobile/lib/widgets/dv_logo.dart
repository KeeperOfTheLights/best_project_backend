import 'package:flutter/material.dart';
import 'dart:math' as math;

// DV Logo Widget - Custom painted logo based on the design
class DVLogo extends StatelessWidget {
  final double size;
  final Color? color;

  const DVLogo({
    super.key,
    this.size = 80,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final logoColor = color ?? Colors.grey[800]!;
    
    return CustomPaint(
      size: Size(size, size),
      painter: _DVLogoPainter(logoColor),
    );
  }
}

class _DVLogoPainter extends CustomPainter {
  final Color color;

  _DVLogoPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.width * 0.35;

    // Draw the arc (incomplete circle from left, top, to right)
    final arcRect = Rect.fromCircle(
      center: Offset(centerX, centerY),
      radius: radius,
    );
    
    // Arc starts at 8 o'clock (210 degrees) and ends at 4 o'clock (330 degrees)
    // This creates an arc that covers left, top, and right sides
    final startAngle = 4 * math.pi / 3; // 240 degrees (8 o'clock adjusted)
    final sweepAngle = 2 * math.pi / 3; // 120 degrees (covers left, top, right)

    canvas.drawArc(
      arcRect,
      startAngle,
      sweepAngle,
      false,
      strokePaint,
    );

    // Draw the markers (short perpendicular lines) at top and bottom of arc
    final topMarkerLength = size.width * 0.08;

    // Top marker (at 12 o'clock - 270 degrees)
    final topAngle = 3 * math.pi / 2; // 270 degrees
    final topX = centerX + radius * math.cos(topAngle);
    final topY = centerY + radius * math.sin(topAngle);
    final topMarkerEndX = topX + topMarkerLength * math.cos(topAngle + math.pi / 2);
    final topMarkerEndY = topY + topMarkerLength * math.sin(topAngle + math.pi / 2);
    
    canvas.drawLine(
      Offset(topX, topY),
      Offset(topMarkerEndX, topMarkerEndY),
      strokePaint,
    );

    // Bottom marker (at 6 o'clock - 90 degrees) - but we need to check if it's in the arc range
    // Since arc goes from 240 to 0 (360), 90 degrees (bottom) is not included
    // So we'll add a marker at the end point of the arc instead
    final bottomAngle = startAngle + sweepAngle; // End of arc
    final bottomX = centerX + radius * math.cos(bottomAngle);
    final bottomY = centerY + radius * math.sin(bottomAngle);
    final bottomMarkerEndX = bottomX + topMarkerLength * math.cos(bottomAngle + math.pi / 2);
    final bottomMarkerEndY = bottomY + topMarkerLength * math.sin(bottomAngle + math.pi / 2);
    
    canvas.drawLine(
      Offset(bottomX, bottomY),
      Offset(bottomMarkerEndX, bottomMarkerEndY),
      strokePaint,
    );

    // Draw "DV" text in the center
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'DV',
        style: TextStyle(
          color: color,
          fontSize: size.width * 0.35,
          fontWeight: FontWeight.bold,
          letterSpacing: -2,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    
    final textOffset = Offset(
      (size.width - textPainter.width) / 2,
      (size.height - textPainter.height) / 2,
    );
    textPainter.paint(canvas, textOffset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

