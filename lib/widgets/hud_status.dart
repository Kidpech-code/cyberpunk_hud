import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/cyber_theme.dart';

/// Blinking status text indicator
class BlinkText extends StatefulWidget {
  final String text;
  final TextStyle? style;

  const BlinkText(this.text, {super.key, this.style});

  @override
  State<BlinkText> createState() => _BlinkTextState();
}

class _BlinkTextState extends State<BlinkText> {
  bool _visible = true;
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(milliseconds: 800), (_) {
      if (mounted) setState(() => _visible = !_visible);
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Opacity(
    // Opacity(1.0) is a Flutter no-op — zero compositor overhead.
    // Opacity(0.0) skips painting entirely without creating an anim layer.
    opacity: _visible ? 1.0 : 0.0,
    child: Text(widget.text, style: widget.style ?? shareTech(12, color: kPrimary)),
  );
}

/// HUD status row: label + value metadata bar
class HudStatusBar extends StatelessWidget {
  final bool top;
  const HudStatusBar({super.key, this.top = true});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(child: BlinkText(top ? '● SYSTEM ONLINE' : '● SECURE CONNECTION', style: shareTech(11, color: kSuccess))),
          Flexible(
            child: Text(
              top ? 'PROTOCOL: OAUTH2' : 'ENCRYPTION: AES-256',
              style: shareTech(11, color: kPrimary.withValues(alpha: 0.6)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Flexible(
            child: Text(
              top ? 'STATUS: STANDBY' : 'NODE: K-2026-X',
              style: shareTech(11, color: kPrimary.withValues(alpha: 0.6)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
