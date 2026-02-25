import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─── State ────────────────────────────────────────────────────────────────────

/// Immutable state model for the main HUD screen.
class HudState {
  const HudState({this.showButton = true, this.showTerminal = false, this.complete = false});

  final bool showButton;
  final bool showTerminal;
  final bool complete;

  HudState copyWith({bool? showButton, bool? showTerminal, bool? complete}) {
    return HudState(showButton: showButton ?? this.showButton, showTerminal: showTerminal ?? this.showTerminal, complete: complete ?? this.complete);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HudState && showButton == other.showButton && showTerminal == other.showTerminal && complete == other.complete;

  @override
  int get hashCode => Object.hash(showButton, showTerminal, complete);
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class HudNotifier extends Notifier<HudState> {
  @override
  HudState build() => const HudState();

  /// User taps "INITIATE SEQUENCE" — show the terminal panel.
  void initiate() {
    state = state.copyWith(showButton: false, showTerminal: true);
  }

  /// Terminal animation finishes — unlock the "ENTER SYSTEM" button.
  void onComplete() {
    state = state.copyWith(complete: true);
  }

  /// Reset everything back to the initial state.
  void reset() {
    state = const HudState();
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final hudProvider = NotifierProvider<HudNotifier, HudState>(HudNotifier.new);
