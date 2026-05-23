// apps/mobile/lib/core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/finanzas/screens/finanzas_screen.dart';
import '../../features/reservas/screens/reservas_screen.dart';
import '../../features/cobranza/screens/cobranza_screen.dart';
import '../../features/chat/screens/chat_screen.dart';
import '../../features/votaciones/screens/votaciones_screen.dart';
import '../screens/home_screen.dart';
import '../screens/splash_screen.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      // Si aún está cargando el estado de autenticación (leyendo de storage/caché)
      // nos quedamos en el Splash para evitar saltos bruscos.
      if (authState.isLoading || authState.isRefreshing) return null;

      final isLoggedIn   = authState.value?.isLoggedIn ?? false;
      final isAuthRoute  = state.matchedLocation.startsWith('/auth');
      final isSplash     = state.matchedLocation == '/splash';

      // 1. Si el usuario ESTÁ logueado
      if (isLoggedIn) {
        // Y está intentando ir a Login o sigue en Splash, lo mandamos al Home
        if (isAuthRoute || isSplash) return '/home';
        return null; // En cualquier otro caso, que siga a donde iba
      }

      // 2. Si el usuario NO está logueado
      if (!isLoggedIn) {
        // Y no está en una ruta de autenticación, lo obligamos a loguearse
        if (!isAuthRoute) return '/auth/login';
        return null; // Si ya está en Login/Registro, no hacemos nada
      }

      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/auth/login',    builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/auth/register', builder: (_, __) => const RegisterScreen()),
      ShellRoute(
        builder: (context, state, child) => HomeScreen(child: child),
        routes: [
          GoRoute(path: '/home',       builder: (_, __) => const FinanzasScreen()),
          GoRoute(path: '/reservas',   builder: (_, __) => const ReservasScreen()),
          GoRoute(path: '/cobranza',   builder: (_, __) => const CobranzaScreen()),
          GoRoute(path: '/chat',       builder: (_, __) => const ChatScreen()),
          GoRoute(path: '/votaciones', builder: (_, __) => const VotacionesScreen()),
        ],
      ),
    ],
  );
}
