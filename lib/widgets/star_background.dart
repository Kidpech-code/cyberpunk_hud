import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// ─── Widget ───────────────────────────────────────────────────────────────────

class StarBackground extends StatefulWidget {
  final bool powerSaveEnabled;

  const StarBackground({super.key, required this.powerSaveEnabled});

  @override
  State<StarBackground> createState() => _StarBackgroundState();
}

/// Holds no mutable UI state — all mutations live in [_StarNotifier].
/// The widget tree never rebuilds on each animation frame; only the canvas
/// repaints via [CustomPaint.repaint].
class _StarBackgroundState extends State<StarBackground> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final _StarNotifier _notifier;
  late final Ticker _ticker;
  Duration _lastTick = Duration.zero;

  Duration get _frameInterval => widget.powerSaveEnabled ? const Duration(milliseconds: 28) : const Duration(milliseconds: 16);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _notifier = _StarNotifier();
    // Ticker advances star positions and calls notifyListeners() directly —
    // no setState, so the widget tree is never rebuilt on each frame.
    final lifecycle = SchedulerBinding.instance.lifecycleState;
    _ticker =
        createTicker(_onTick)
          ..muted = lifecycle != null && lifecycle != AppLifecycleState.resumed
          ..start();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _ticker.muted = state != AppLifecycleState.resumed;
    if (state == AppLifecycleState.resumed) {
      _lastTick = Duration.zero;
    }
  }

  @override
  void didUpdateWidget(covariant StarBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.powerSaveEnabled != widget.powerSaveEnabled) {
      _lastTick = Duration.zero;
      _notifier.reconfigure(powerSaveEnabled: widget.powerSaveEnabled);
    }
  }

  void _onTick(Duration elapsed) {
    if (_lastTick == Duration.zero) {
      _lastTick = elapsed;
      return;
    }

    final dt = elapsed - _lastTick;
    if (dt < _frameInterval) return;

    _lastTick = elapsed;
    final speedScale = dt.inMicroseconds / 16667.0; // normalize around 60fps
    _notifier.tick(speedScale: speedScale, powerSaveEnabled: widget.powerSaveEnabled);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker.dispose();
    _notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      // Update mouse without setState — the next tick will pick it up.
      onPointerHover: (e) => _notifier.mouse = e.localPosition,
      behavior: HitTestBehavior.translucent,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          _notifier.ensureInitialized(size, powerSaveEnabled: widget.powerSaveEnabled);
          // repaint: _notifier — Flutter repaints only the canvas leaf when
          // the notifier fires, never the widget tree above it.
          return CustomPaint(painter: _StarPainter(_notifier), size: size);
        },
      ),
    );
  }
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

/// Owns star data and advances physics each frame.
class _StarNotifier extends ChangeNotifier {
  Offset mouse = Offset.zero;

  final List<_Star> _stars = [];
  final _rng = Random();
  Size _size = Size.zero;

  static const int _kMinCountSave = 180;
  static const int _kMaxCountSave = 520;
  static const int _kMinCountFull = 460;
  static const int _kMaxCountFull = 800;
  static const double _kSpeedSave = 0.1;
  static const double _kSpeedFull = 0.18;

  List<_Star> get stars => _stars;
  Size get size => _size;

  void ensureInitialized(Size size, {required bool powerSaveEnabled}) {
    if (_size == size) return;
    _size = size;
    _stars.clear();
    final targetCount = _starCountFor(size, powerSaveEnabled: powerSaveEnabled);
    for (int i = 0; i < targetCount; i++) {
      _stars.add(_Star.random(_rng, size));
    }
  }

  void reconfigure({required bool powerSaveEnabled}) {
    if (_size == Size.zero) return;

    final targetCount = _starCountFor(_size, powerSaveEnabled: powerSaveEnabled);
    final currentCount = _stars.length;
    if (currentCount < targetCount) {
      for (int i = currentCount; i < targetCount; i++) {
        _stars.add(_Star.random(_rng, _size));
      }
    } else if (currentCount > targetCount) {
      _stars.removeRange(targetCount, currentCount);
    }
    notifyListeners();
  }

  int _starCountFor(Size size, {required bool powerSaveEnabled}) {
    if (size.width == 0 || size.height == 0) return powerSaveEnabled ? _kMinCountSave : _kMinCountFull;
    final area = size.width * size.height;
    final scaled = powerSaveEnabled ? (area / 4200).round() : (area / 3200).round();
    final minCount = powerSaveEnabled ? _kMinCountSave : _kMinCountFull;
    final maxCount = powerSaveEnabled ? _kMaxCountSave : _kMaxCountFull;
    return scaled.clamp(minCount, maxCount);
  }

  /// Advance star positions and notify the painter. No setState involved.
  void tick({double speedScale = 1.0, required bool powerSaveEnabled}) {
    final w = _size.width;
    final h = _size.height;
    if (w == 0 || h == 0) return;
    final baseSpeed = powerSaveEnabled ? _kSpeedSave : _kSpeedFull;
    final maxSpeed = powerSaveEnabled ? 0.5 : 0.8;
    final frameSpeed = (baseSpeed * speedScale).clamp(0.08, maxSpeed);

    for (final s in _stars) {
      s.z -= frameSpeed;
      if (s.z <= 0) {
        s.z = w;
        s.x = _rng.nextDouble() * w - w / 2;
        s.y = _rng.nextDouble() * h - h / 2;
      }
    }
    notifyListeners();
  }
}

// ─── Data ─────────────────────────────────────────────────────────────────────

class _Star {
  double x, y, z;
  _Star(this.x, this.y, this.z);

  factory _Star.random(Random rng, Size s) =>
      _Star(rng.nextDouble() * s.width - s.width / 2, rng.nextDouble() * s.height - s.height / 2, rng.nextDouble() * s.width);
}

// ─── Painter ──────────────────────────────────────────────────────────────────

class _StarPainter extends CustomPainter {
  final _StarNotifier _n;

  // Reuse a single Paint object across frames — avoids allocation pressure.
  final _paint = Paint();
  final _bgPaint = Paint()..color = const Color(0xFF020408);

  _StarPainter(this._n) : super(repaint: _n);

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final stars = _n.stars;
    final mouse = _n.mouse;
    final size = _n.size;
    final w = size.width;
    final h = size.height;
    if (w == 0 || h == 0) return;

    canvas.drawRect(Offset.zero & canvasSize, _bgPaint);

    for (final s in stars) {
      final px = (s.x / s.z) * w + w / 2;
      final py = (s.y / s.z) * h + h / 2;
      final ox = (mouse.dx - w / 2) * 0.05 * (w / s.z);
      final oy = (mouse.dy - h / 2) * 0.05 * (w / s.z);
      final radius = max(0.1, (1 - s.z / w) * 2.5);
      final brightness = (1 - s.z / w).clamp(0.0, 1.0);

      _paint.color = Colors.white.withValues(alpha: brightness * 0.9 + 0.1);
      canvas.drawCircle(Offset(px + ox, py + oy), radius, _paint);
    }
  }

  /// shouldRepaint is irrelevant here — repaints are driven entirely by the
  /// [repaint] listenable passed to super(). Return false to skip the check.
  @override
  bool shouldRepaint(covariant _StarPainter old) => false;
}
