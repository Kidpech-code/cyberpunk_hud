import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/performance_provider.dart';
import '../theme/cyber_theme.dart';
import '../widgets/crt_overlay.dart';
import '../widgets/cyber_card.dart';
import '../widgets/hud_corners.dart';

class PerformanceSettingsScreen extends ConsumerWidget {
  const PerformanceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final powerSaveEnabled = ref.watch(performanceProvider);
    final notifier = ref.read(performanceProvider.notifier);
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: kBg,
      body: Stack(
        children: [
          const Positioned.fill(child: ColoredBox(color: kBg)),
          const RepaintBoundary(child: HudCorners()),
          const Positioned.fill(child: RepaintBoundary(child: CrtOverlay())),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: kPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Performance',
                          textAlign: TextAlign.center,
                          style: orbitron(20, letterSpacing: 2.5),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: width < 560 ? width - 40 : 520,
                    child: CyberCard(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        child: SwitchListTile(
                          value: powerSaveEnabled,
                          activeThumbColor: kSuccess,
                          activeTrackColor: kSuccess.withValues(alpha: 0.35),
                          inactiveThumbColor: kPrimary,
                          inactiveTrackColor: kPrimary.withValues(alpha: 0.25),
                          title: Text(
                            'Power Save',
                            style: shareTech(
                              16,
                              color: kPrimary,
                              letterSpacing: 1.2,
                            ),
                          ),
                          subtitle: Text(
                            powerSaveEnabled
                                ? 'Battery optimized: lower animation workload and frame cadence.'
                                : 'Maximum visual performance: higher animation workload and cadence.',
                            style: shareTech(
                              12,
                              color: kPrimary.withValues(alpha: 0.75),
                            ),
                          ),
                          onChanged: (value) {
                            notifier.setEnabled(value);
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
