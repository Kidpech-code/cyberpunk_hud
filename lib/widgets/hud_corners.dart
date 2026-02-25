import 'package:flutter/material.dart';
import '../theme/cyber_theme.dart';

/// Four L-shaped HUD corner brackets rendered at screen edges
class HudCorners extends StatelessWidget {
  final double size;
  final double margin;
  final double strokeWidth;
  final double radius;

  const HudCorners({
    super.key,
    this.size = 120,
    this.margin = 20,
    this.strokeWidth = 2,
    this.radius = 14,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox.expand(
        child: Stack(
          children: [
            // Top-left
            Positioned(
              top: margin,
              left: margin,
              child: _Corner(
                size: size,
                strokeWidth: strokeWidth,
                radius: radius,
                top: true,
                left: true,
              ),
            ),
            // Top-right
            Positioned(
              top: margin,
              right: margin,
              child: _Corner(
                size: size,
                strokeWidth: strokeWidth,
                radius: radius,
                top: true,
                left: false,
              ),
            ),
            // Bottom-left
            Positioned(
              bottom: margin,
              left: margin,
              child: _Corner(
                size: size,
                strokeWidth: strokeWidth,
                radius: radius,
                top: false,
                left: true,
              ),
            ),
            // Bottom-right
            Positioned(
              bottom: margin,
              right: margin,
              child: _Corner(
                size: size,
                strokeWidth: strokeWidth,
                radius: radius,
                top: false,
                left: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Corner extends StatelessWidget {
  final double size;
  final double strokeWidth;
  final double radius;
  final bool top;
  final bool left;

  const _Corner({
    required this.size,
    required this.strokeWidth,
    required this.radius,
    required this.top,
    required this.left,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.7,
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _CornerPainter(
            strokeWidth: strokeWidth,
            radius: radius,
            top: top,
            left: left,
          ),
        ),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final double strokeWidth;
  final double radius;
  final bool top;
  final bool left;

  _CornerPainter({
    required this.strokeWidth,
    required this.radius,
    required this.top,
    required this.left,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = kPrimary
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.square;

    // Add glow
    final glowPaint =
        Paint()
          ..color = kPrimary.withValues(alpha: 0.3)
          ..strokeWidth = strokeWidth + 4
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.square
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final path = _buildPath(size);
    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, paint);
  }

  Path _buildPath(Size s) {
    final path = Path();
    final w = s.width;
    final h = s.height;
    final r = radius;

    if (top && left) {
      // ┌ corner: draw top edge and left edge
      path.moveTo(w, 0);
      path.lineTo(r, 0);
      path.arcToPoint(
        Offset(0, r),
        radius: Radius.circular(r),
        clockwise: false,
      );
      path.lineTo(0, h);
    } else if (top && !left) {
      // ┐ corner
      path.moveTo(0, 0);
      path.lineTo(w - r, 0);
      path.arcToPoint(
        Offset(w, r),
        radius: Radius.circular(r),
        clockwise: true,
      );
      path.lineTo(w, h);
    } else if (!top && left) {
      // └ corner
      path.moveTo(w, h);
      path.lineTo(0, h - r + 0);
      path.lineTo(0, h - r);
      path.arcToPoint(
        Offset(r, h),
        radius: Radius.circular(r),
        clockwise: false,
      );
      path.moveTo(0, h - r);
      // redraw cleanly
      final p2 = Path();
      p2.moveTo(w, h);
      p2.lineTo(0, h);
      // just draw two lines
      final p3 = Path();
      p3.moveTo(w, h);
      p3.lineTo(0, h - 0);
      p3.moveTo(0, 0);
      p3.lineTo(0, h);
      // Use simpler approach
      return _simplePath(s);
    } else {
      return _simplePath(s);
    }

    return path;
  }

  Path _simplePath(Size s) {
    final path = Path();
    final w = s.width;
    final h = s.height;
    final r = radius;

    if (top && left) {
      path.moveTo(w, 0);
      path.lineTo(r, 0);
      path.arcToPoint(
        Offset(0, r),
        radius: Radius.circular(r),
        clockwise: false,
      );
      path.lineTo(0, h);
    } else if (top && !left) {
      path.moveTo(0, 0);
      path.lineTo(w - r, 0);
      path.arcToPoint(
        Offset(w, r),
        radius: Radius.circular(r),
        clockwise: true,
      );
      path.lineTo(w, h);
    } else if (!top && left) {
      path.moveTo(w, h);
      path.lineTo(r, h);
      path.arcToPoint(
        Offset(0, h - r),
        radius: Radius.circular(r),
        clockwise: false,
      );
      path.lineTo(0, 0);
    } else {
      // bottom-right
      path.moveTo(0, h);
      path.lineTo(w - r, h);
      path.arcToPoint(
        Offset(w, h - r),
        radius: Radius.circular(r),
        clockwise: true,
      );
      path.lineTo(w, 0);
    }
    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
