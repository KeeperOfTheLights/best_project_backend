import 'package:flutter/material.dart';
import 'dart:math' as math;

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

    final arcRect = Rect.fromCircle(
      center: Offset(centerX, centerY),
      radius: radius,
    );


    final startAngle = 4 * math.pi / 3;
    final sweepAngle = 2 * math.pi / 3;

    canvas.drawArc(
      arcRect,
      startAngle,
      sweepAngle,
      false,
      strokePaint,
    );

    final topMarkerLength = size.width * 0.08;

    final topAngle = 3 * math.pi / 2;
    final topX = centerX + radius * math.cos(topAngle);
    final topY = centerY + radius * math.sin(topAngle);
    final topMarkerEndX = topX + topMarkerLength * math.cos(topAngle + math.pi / 2);
    final topMarkerEndY = topY + topMarkerLength * math.sin(topAngle + math.pi / 2);
    
    canvas.drawLine(
      Offset(topX, topY),
      Offset(topMarkerEndX, topMarkerEndY),
      strokePaint,
    );



    final bottomAngle = startAngle + sweepAngle;
    final bottomX = centerX + radius * math.cos(bottomAngle);
    final bottomY = centerY + radius * math.sin(bottomAngle);
    final bottomMarkerEndX = bottomX + topMarkerLength * math.cos(bottomAngle + math.pi / 2);
    final bottomMarkerEndY = bottomY + topMarkerLength * math.sin(bottomAngle + math.pi / 2);
    
    canvas.drawLine(
      Offset(bottomX, bottomY),
      Offset(bottomMarkerEndX, bottomMarkerEndY),
      strokePaint,
    );

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

