import 'package:flutter/material.dart';
import '../background_painter.dart';

class BackgroundContainer extends StatelessWidget {
  final Widget child;
  final bool withFrost;
  
  const BackgroundContainer({
    super.key,
    required this.child,
    this.withFrost = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Gradient background
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary.withOpacity(0.8),
                Theme.of(context).colorScheme.secondary.withOpacity(0.5),
                Theme.of(context).colorScheme.tertiary.withOpacity(0.3),
              ],
            ),
          ),
        ),
        // Decorative icons
        CustomPaint(
          painter: BackgroundIconPainter(
            color: Colors.white.withOpacity(0.05),
          ),
          child: Container(),
        ),
        // Main content
        child,
      ],
    );
  }
} 