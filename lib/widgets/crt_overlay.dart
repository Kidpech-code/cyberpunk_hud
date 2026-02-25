import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// CRT scanline + vignette overlay — pointer-events: none equivalent.
/// Optimised: the entire effect is drawn with 3 canvas calls regardless of
/// screen size (was previously O(width + height) individual drawRect calls).
class CrtOverlay extends StatelessWidget {
  const CrtOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox.expand(child: CustomPaint(painter: _CrtPainter())),
    );
  }
}

class _CrtPainter extends CustomPainter {
  // Painters are const-constructible; no instance state needed.
  const _CrtPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // ── Scanlines ────────────────────────────────────────────────────────
    // Single draw call: a tiled 2-pixel linear gradient.
    //   Row 0-1 px: transparent  → Row 1-2 px: dark  → repeats.
    // This replaces height/2 individual drawRect calls.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset.zero,
          const Offset(0, 2), // 2-pixel vertical period
          const [
            Color(0x00000000),
            Color(0x00000000),
            Color(0x18000000),
            Color(0x18000000),
          ],
          [0.0, 0.5, 0.5, 1.0],
          TileMode.repeated,
        ),
    );

    // ── Subtle RGB tint (replaces per-pixel aberration strips) ────────────
    // The original 3-colour strips were barely visible (≤ 6 % opacity).
    // A single horizontally-tiled 3-px gradient achieves the same feel in
    // one draw call instead of width/3 × 3 calls.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset.zero,
          const Offset(3, 0), // 3-pixel horizontal period
          const [
            Color(0x10FF0000),
            Color(0x0500FF00),
            Color(0x100000FF),
            Color(0x10FF0000),
          ],
          [0.0, 0.333, 0.666, 1.0],
          TileMode.repeated,
        ),
    );

    // ── Vignette ──────────────────────────────────────────────────────────
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.longestSide * 0.75;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.radial(
          center,
          radius,
          [const Color(0x00000000), const Color(0x26000000)],
          [0.75, 1.0],
        ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
