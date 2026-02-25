import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/cyber_theme.dart';

enum LogType { normal, success, warning, error }

class LogEntry {
  final String message;
  final LogType type;
  final Duration delay;
  const LogEntry(this.message, this.type, this.delay);
}

Color _logColor(LogType t) {
  switch (t) {
    case LogType.success:
      return kSuccess;
    case LogType.warning:
      return kWarning;
    case LogType.error:
      return kError;
    case LogType.normal:
      return kPrimary;
  }
}

/// Terminal-style log panel with color-coded animated lines
class TerminalPanel extends StatefulWidget {
  final List<LogEntry> logs;
  final double height;
  final VoidCallback? onComplete;

  const TerminalPanel({
    super.key,
    required this.logs,
    this.height = 220,
    this.onComplete,
  });

  @override
  State<TerminalPanel> createState() => _TerminalPanelState();
}

class _TerminalPanelState extends State<TerminalPanel> {
  final List<_Line> _visible = [];
  final ScrollController _scroll = ScrollController();
  bool _blinkOn = true;
  Timer? _blinkTimer;
  int _logIndex = 0;

  @override
  void initState() {
    super.initState();
    _scheduleNext();
    _blinkTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (mounted) setState(() => _blinkOn = !_blinkOn);
    });
  }

  void _scheduleNext() {
    if (_logIndex >= widget.logs.length) {
      widget.onComplete?.call();
      return;
    }
    final log = widget.logs[_logIndex++];
    Future.delayed(log.delay, () {
      if (!mounted) return;
      setState(() {
        _visible.add(_Line(log.message, log.type));
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) {
          _scroll.animateTo(
            _scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
          );
        }
      });
      _scheduleNext();
    });
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        border: const Border(
          left: BorderSide(color: kSecondary, width: 2),
          top: BorderSide(color: kSecondary, width: 1),
          bottom: BorderSide(color: kSecondary, width: 1),
          right: BorderSide(color: kSecondary, width: 1),
        ),
      ),
      child: ListView.builder(
        controller: _scroll,
        padding: const EdgeInsets.all(12),
        itemCount: _visible.length + 1,
        itemBuilder: (_, i) {
          if (i == _visible.length) {
            // blinking cursor
            return Text(
              '> ${_blinkOn ? '_' : ' '}',
              style: shareTech(13, color: kPrimary.withValues(alpha: 0.6)),
            );
          }
          final line = _visible[i];
          return _FadeInLine(
            key: ValueKey(i),
            child: Text(
              '> ${line.message}',
              style: shareTech(13, color: _logColor(line.type)),
            ),
          );
        },
      ),
    );
  }
}

class _Line {
  final String message;
  final LogType type;
  _Line(this.message, this.type);
}

class _FadeInLine extends StatefulWidget {
  final Widget child;
  const _FadeInLine({super.key, required this.child});

  @override
  State<_FadeInLine> createState() => _FadeInLineState();
}

class _FadeInLineState extends State<_FadeInLine>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _a;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _a = CurvedAnimation(parent: _c, curve: Curves.easeIn);
    _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      FadeTransition(opacity: _a, child: widget.child);
}
