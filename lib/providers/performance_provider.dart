import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

class PerformanceNotifier extends Notifier<bool> {
  static const _storageKey = 'power_save_enabled';
  static const _boxName = 'app_settings';

  @override
  bool build() {
    _hydrateFromStorage();
    return true;
  }

  Future<void> _hydrateFromStorage() async {
    try {
      final box = await _openBox();
      if (box == null) return;
      final saved = box.get(_storageKey) as bool?;
      if (saved != null && saved != state) {
        state = saved;
      }
    } on HiveError {
      return;
    }
  }

  Future<void> toggle() async {
    await setEnabled(!state);
  }

  Future<void> setEnabled(bool value) async {
    if (state == value) return;
    state = value;
    try {
      final box = await _openBox();
      if (box == null) return;
      await box.put(_storageKey, value);
    } on HiveError {
      return;
    }
  }

  Future<Box<dynamic>?> _openBox() async {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box(_boxName);
    }
    return Hive.openBox(_boxName);
  }
}

final performanceProvider = NotifierProvider<PerformanceNotifier, bool>(
  PerformanceNotifier.new,
);
