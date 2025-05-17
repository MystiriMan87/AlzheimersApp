import 'package:flutter/material.dart';
import 'dart:math' as math;

class BackgroundIconPainter extends CustomPainter {
  final Color color;
  
  BackgroundIconPainter({
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final random = math.Random(42); // Fixed seed for consistent pattern
    final iconSize = size.width * 0.05; // 5% of screen width

    // List of icon paths to draw
    final paths = [
      // Bell icon
      Path()
        ..moveTo(0, 0)
        ..addOval(Rect.fromCircle(center: Offset(iconSize/2, iconSize/2), radius: iconSize/2))
        ..moveTo(iconSize/4, iconSize)
        ..lineTo(iconSize*3/4, iconSize)
        ..moveTo(iconSize/2, 0)
        ..lineTo(iconSize/2, iconSize/4),

      // Star icon
      Path()
        ..moveTo(iconSize/2, 0)
        ..lineTo(iconSize*0.65, iconSize*0.35)
        ..lineTo(iconSize, iconSize*0.35)
        ..lineTo(iconSize*0.75, iconSize*0.6)
        ..lineTo(iconSize*0.85, iconSize)
        ..lineTo(iconSize/2, iconSize*0.75)
        ..lineTo(iconSize*0.15, iconSize)
        ..lineTo(iconSize*0.25, iconSize*0.6)
        ..lineTo(0, iconSize*0.35)
        ..lineTo(iconSize*0.35, iconSize*0.35)
        ..close(),

      // Clock icon
      Path()
        ..addOval(Rect.fromCircle(center: Offset(iconSize/2, iconSize/2), radius: iconSize/2))
        ..moveTo(iconSize/2, iconSize/2)
        ..lineTo(iconSize*0.7, iconSize*0.7),

      // Calendar icon
      Path()
        ..addRect(Rect.fromLTWH(0, iconSize*0.2, iconSize, iconSize*0.8))
        ..moveTo(iconSize*0.2, 0)
        ..lineTo(iconSize*0.2, iconSize*0.3)
        ..moveTo(iconSize*0.8, 0)
        ..lineTo(iconSize*0.8, iconSize*0.3),
    ];

    // Draw icons in a grid pattern
    for (var i = 0; i < size.width / (iconSize * 3); i++) {
      for (var j = 0; j < size.height / (iconSize * 3); j++) {
        final x = i * iconSize * 3 + random.nextDouble() * iconSize;
        final y = j * iconSize * 3 + random.nextDouble() * iconSize;
        
        canvas.save();
        canvas.translate(x, y);
        canvas.rotate(random.nextDouble() * math.pi * 2);
        
        // Randomly select and draw an icon
        final path = paths[random.nextInt(paths.length)];
        canvas.drawPath(path, paint);
        
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 