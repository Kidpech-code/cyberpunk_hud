import 'package:flutter/material.dart';
import '../theme/cyber_theme.dart';

/// Glassmorphism card with cyberpunk clip-path cut corners + scanner line
class CyberCard extends StatelessWidget {
  final Widget child;
  final double cutSize;

  const CyberCard({super.key, required this.child, this.cutSize = 20});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _CyberClipper(cut: cutSize),
      child: Stack(
        children: [
          // Glass background
          Container(
            decoration: BoxDecoration(
              color: kCardBg,
              border: Border.all(color: kPrimaryBorder, width: 1),
              boxShadow: const [BoxShadow(color: kPrimaryGlow, blurRadius: 50)],
            ),
            child: child,
          ),

          // Top glowing border
          Positioned(
            top: 0,
            left: cutSize,
            right: 0,
            child: Container(
              height: 1.5,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [kPrimary, kPrimary.withValues(alpha: 0.4)],
                ),
                boxShadow: [BoxShadow(color: kPrimary, blurRadius: 10)],
              ),
            ),
          ),

          // Bottom glowing border
          Positioned(
            bottom: 0,
            left: 0,
            right: cutSize,
            child: Container(
              height: 1.5,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [kPrimary.withValues(alpha: 0.4), kPrimary],
                ),
                boxShadow: [BoxShadow(color: kPrimary, blurRadius: 10)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CyberClipper extends CustomClipper<Path> {
  final double cut;
  const _CyberClipper({required this.cut});

  @override
  Path getClip(Size size) {
    final c = cut;
    return Path()
      ..moveTo(c, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height - c)
      ..lineTo(size.width - c, size.height)
      ..lineTo(0, size.height)
      ..lineTo(0, c)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> old) => false;
}
