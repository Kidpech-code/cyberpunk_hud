import 'dart:io';

import 'package:hive/hive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cyberpunk_hud/main.dart';

void main() {
  setUpAll(() async {
    final dir = await Directory.systemTemp.createTemp('cyberpunk_hud_test_');
    Hive.init(dir.path);
  });

  tearDownAll(() async {
    await Hive.deleteFromDisk();
  });

  testWidgets('App smoke test', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: CyberpunkApp()));
    expect(find.byType(CyberpunkApp), findsOneWidget);
  });
}
