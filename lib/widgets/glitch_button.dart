import 'package:flutter/material.dart';
import '../theme/cyber_theme.dart';

/// Button with "slide fill from left" hover effect (glitch style)
class GlitchButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final double height;

  const GlitchButton({
    super.key,
    required this.label,
    this.onPressed,
    this.color = kPrimary,
    this.height = 56,
  });

  @override
  State<GlitchButton> createState() => _GlitchButtonState();
}

class _GlitchButtonState extends State<GlitchButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fill;
  bool _hovering = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fill = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onHover(bool h) {
    setState(() => _hovering = h);
    if (h) {
      _ctrl.forward();
    } else {
      _ctrl.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedBuilder(
          animation: _fill,
          builder: (_, __) {
            return Container(
              height: widget.height,
              decoration: BoxDecoration(
                border: Border.all(color: widget.color, width: 2),
                boxShadow:
                    _hovering
                        ? [
                          BoxShadow(
                            color: widget.color.withValues(alpha: 0.5),
                            blurRadius: 24,
                          ),
                        ]
                        : [],
              ),
              child: Stack(
                children: [
                  // Fill layer (slides from left)
                  Positioned.fill(
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: _fill.value,
                      child: Container(color: widget.color),
                    ),
                  ),
                  // Label
                  Center(
                    child: Text(
                      widget.label,
                      style: orbitron(
                        14,
                        color: _hovering ? Colors.black : widget.color,
                        letterSpacing: 3,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
