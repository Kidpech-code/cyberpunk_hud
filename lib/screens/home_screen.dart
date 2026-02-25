import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/hud_provider.dart';
import '../providers/performance_provider.dart';
import '../routes/app_routes.dart';
import '../theme/cyber_theme.dart';
import '../widgets/star_background.dart';
import '../widgets/crt_overlay.dart';
import '../widgets/hud_corners.dart';
import '../widgets/hud_status.dart';
import '../widgets/cyber_card.dart';
import '../widgets/glitch_button.dart';
import '../widgets/terminal_panel.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin {
  // Tilt uses a ValueNotifier so that only the Transform node rebuilds on each
  // pointer-move event — the rest of the widget tree stays untouched.
  final _tilt = ValueNotifier<Offset>(Offset.zero);

  // Animation controller requires a vsync (TickerProvider) so it lives here.
  late AnimationController _entryCtrl;
  late Animation<double> _entryScale;
  late Animation<double> _entryOpacity;

  static final _logs = [
    const LogEntry('Initializing neural interface...', LogType.normal, Duration(milliseconds: 300)),
    const LogEntry('Scanning biometric data...', LogType.normal, Duration(milliseconds: 900)),
    const LogEntry('WARNING: Firewall detected (Layer 7)', LogType.warning, Duration(milliseconds: 1600)),
    const LogEntry('Bypassing firewall... [OK]', LogType.normal, Duration(milliseconds: 2400)),
    const LogEntry('Establishing encrypted tunnel...', LogType.normal, Duration(milliseconds: 3100)),
    const LogEntry('ERROR: Anomaly detected at node 0x7F', LogType.error, Duration(milliseconds: 3700)),
    const LogEntry('Recalibrating quantum keys...', LogType.normal, Duration(milliseconds: 4400)),
    const LogEntry('Authentication SUCCESS', LogType.success, Duration(milliseconds: 5200)),
    const LogEntry('Welcome, Operator. System is yours.', LogType.success, Duration(milliseconds: 5900)),
  ];

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _entryScale = Tween<double>(begin: 0.85, end: 1.0).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutBack));
    _entryOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeIn));
    _entryCtrl.forward();
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _tilt.dispose();
    super.dispose();
  }

  void _onMouseMove(PointerEvent e, Size screen) {
    _tilt.value = Offset((screen.width / 2 - e.position.dx) / 25, (screen.height / 2 - e.position.dy) / 25);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final powerSaveEnabled = ref.watch(performanceProvider);

    return Scaffold(
      backgroundColor: kBg,
      body: MouseRegion(
        onHover: (e) => _onMouseMove(e, size),
        child: Stack(
          children: [
            // Layer 0: Star warp background — RepaintBoundary isolates the
            // 60 fps canvas repaints from every other layer in the Stack.
            Positioned.fill(child: RepaintBoundary(child: StarBackground(powerSaveEnabled: powerSaveEnabled))),

            // Layer 5: HUD corners — static, isolated so star repaints don't
            // propagate up and trigger unnecessary compositing.
            const RepaintBoundary(child: HudCorners()),

            // Layer 10: CRT overlay — also static after first paint.
            const Positioned.fill(child: RepaintBoundary(child: CrtOverlay())),

            // Top HUD status bar
            const Positioned(top: 0, left: 0, right: 0, child: SafeArea(child: HudStatusBar(top: true))),

            // Bottom HUD status bar
            const Positioned(bottom: 0, left: 0, right: 0, child: SafeArea(child: HudStatusBar(top: false))),

            // Layer 20: Main content card.
            // ListenableBuilder re-runs only its builder lambda on tilt change,
            // leaving ScaleTransition / FadeTransition / CyberCard untouched.
            Center(
              child: ScaleTransition(
                scale: _entryScale,
                child: FadeTransition(
                  opacity: _entryOpacity,
                  child: ListenableBuilder(
                    listenable: _tilt,
                    // child is built once and reused; the Transform is rebuilt
                    // cheaply since it only updates a 4×4 matrix node.
                    child: SizedBox(
                      width: _cardWidth(size),
                      child: CyberCard(
                        child: Padding(padding: const EdgeInsets.all(40), child: _CardContent(logs: _logs, powerSaveEnabled: powerSaveEnabled)),
                      ),
                    ),
                    builder:
                        (_, child) => Transform(
                          alignment: Alignment.center,
                          transform:
                              Matrix4.identity()
                                ..setEntry(3, 2, 0.001)
                                ..rotateY(_tilt.value.dx * 0.03)
                                ..rotateX(-_tilt.value.dy * 0.03),
                          child: child,
                        ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _cardWidth(Size size) {
    if (size.width < 500) return size.width * 0.9;
    return 440;
  }
}

// ─── Card Content ─────────────────────────────────────────────────────────────
// Uses ConsumerWidget so it watches hudProvider directly and calls the notifier's
// actions without requiring any state to be passed down from the parent.

class _CardContent extends ConsumerWidget {
  final List<LogEntry> logs;
  final bool powerSaveEnabled;

  const _CardContent({required this.logs, required this.powerSaveEnabled});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hud = ref.watch(hudProvider);
    final notifier = ref.read(hudProvider.notifier);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'POWER SAVE: ${powerSaveEnabled ? 'ON' : 'OFF'}',
              style: shareTech(10, color: powerSaveEnabled ? kSuccess : kPrimary.withValues(alpha: 0.7), letterSpacing: 1.8),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pushNamed(AppRoutes.performanceSettings),
              child: Text('SETTINGS', style: shareTech(10, color: kPrimary, letterSpacing: 1.8)),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // ── Header ─────────────────────────────────────────────────────────
        Text('NEURAL\nINTERFACE', textAlign: TextAlign.center, style: orbitron(28, weight: FontWeight.w900, letterSpacing: 4)),
        const SizedBox(height: 8),
        Text('CYBERPUNK HUD v2.0', textAlign: TextAlign.center, style: orbitron(11, color: kSecondary, letterSpacing: 6, weight: FontWeight.w400)),
        const SizedBox(height: 4),
        Text('SYSTEM ID: K-2026-X', textAlign: TextAlign.center, style: shareTech(11, color: kPrimary.withValues(alpha: 0.45))),
        const SizedBox(height: 32),

        // ── Separator ──────────────────────────────────────────────────────
        _GlowDivider(),
        const SizedBox(height: 28),

        // ── Status indicators ──────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [_StatusChip('POWER', '100%', kSuccess), _StatusChip('SIGNAL', 'LOCKED', kPrimary), _StatusChip('THREAT', 'LOW', kWarning)],
        ),
        const SizedBox(height: 28),

        // ── Terminal or Button ─────────────────────────────────────────────
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
          child:
              hud.showTerminal
                  ? Column(
                    key: const ValueKey('terminal'),
                    children: [
                      TerminalPanel(logs: logs, height: 200, onComplete: notifier.onComplete),
                      if (hud.complete) ...[
                        const SizedBox(height: 16),
                        GlitchButton(label: 'ENTER SYSTEM', color: kSuccess, onPressed: notifier.reset),
                      ],
                    ],
                  )
                  : Column(
                    key: const ValueKey('button'),
                    children: [
                      GlitchButton(label: 'INITIATE SEQUENCE', onPressed: notifier.initiate),
                      const SizedBox(height: 16),
                      GlitchButton(label: 'ABORT', color: kAlert),
                    ],
                  ),
        ),
      ],
    );
  }
}

class _GlowDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            kPrimary.withValues(alpha: 0.8),
            kSecondary.withValues(alpha: 0.8),
            kPrimary.withValues(alpha: 0.8),
            Colors.transparent,
          ],
        ),
        boxShadow: [BoxShadow(color: kPrimary.withValues(alpha: 0.4), blurRadius: 8)],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatusChip(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: shareTech(10, color: kPrimary.withValues(alpha: 0.5))),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(border: Border.all(color: color.withValues(alpha: 0.5)), color: color.withValues(alpha: 0.08)),
          child: Text(value, style: shareTech(12, color: color)),
        ),
      ],
    );
  }
}
