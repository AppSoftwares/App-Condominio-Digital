// apps/mobile/lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/cache/cache_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();
  await Firebase.initializeApp();
  await HiveFlutter.initFlutter();
  await CacheManager.init(); // registra los boxes de Hive

  runApp(const ProviderScope(child: CondominioApp()));
}

class CondominioApp extends ConsumerWidget {
  const CondominioApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Condominio',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
