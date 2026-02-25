import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'routes/app_routes.dart';
import 'screens/performance_settings_screen.dart';
import 'theme/cyber_theme.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const ProviderScope(child: CyberpunkApp()));
}

class CyberpunkApp extends StatelessWidget {
  const CyberpunkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CYBER HUD',
      debugShowCheckedModeBanner: false,
      theme: cyberTheme(),
      initialRoute: AppRoutes.home,
      routes: {AppRoutes.home: (_) => const HomeScreen(), AppRoutes.performanceSettings: (_) => const PerformanceSettingsScreen()},
    );
  }
}
