import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/perfil_screen.dart';
import '../../features/finanzas/screens/finanzas_screen.dart';
import '../../features/reservas/screens/reservas_screen.dart';
import '../../features/cobranza/screens/cobranza_screen.dart';
import '../../features/chat/screens/chat_screen.dart';
import '../../features/votaciones/screens/votaciones_screen.dart';
import '../../features/visitas/screens/registrar_visita_screen.dart';
import '../../features/bitacora/screens/bitacora_screen.dart';
import '../../features/mantenimiento/screens/mantenimiento_screen.dart';
import '../../features/comunidad/screens/comunidad_screen.dart';
import '../../features/correspondencia/screens/correspondencia_screen.dart';
import '../../features/home/screens/home_content_screen.dart';
import '../../features/home/screens/conjuntos_screen.dart';
import '../screens/home_screen.dart';
import '../screens/splash_screen.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      if (authState.isLoading || authState.isRefreshing) return null;

      final isLoggedIn   = authState.value?.isLoggedIn ?? false;
      final isAuthRoute  = state.matchedLocation.startsWith('/auth');
      final isSplash     = state.matchedLocation == '/splash';

      if (isLoggedIn) {
        if (isAuthRoute || isSplash) return '/home';
        return null;
      }

      if (!isLoggedIn) {
        if (!isAuthRoute) return '/auth/login';
        return null;
      }

      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/auth/login',    builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/auth/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/perfil', builder: (_, __) => const PerfilScreen()),
      GoRoute(path: '/conjuntos', builder: (_, __) => const ConjuntosScreen()),
      ShellRoute(
        builder: (context, state, child) => HomeScreen(child: child),
        routes: [
          GoRoute(path: '/home',       builder: (_, __) => const HomeContentScreen()),
          GoRoute(path: '/reservas',   builder: (_, __) => const ReservasScreen()),
          GoRoute(path: '/cobranza',   builder: (_, __) => const CobranzaScreen()),
          GoRoute(path: '/chat',       builder: (_, __) => const ChatScreen()),
          GoRoute(path: '/votaciones', builder: (_, __) => const VotacionesScreen()),
          GoRoute(path: '/visitas',    builder: (_, __) => const RegistrarVisitaScreen()),
          GoRoute(path: '/bitacora',   builder: (_, __) => const BitacoraScreen()),
          GoRoute(path: '/mantenimiento', builder: (_, __) => const MantenimientoScreen()),
          GoRoute(path: '/comunidad',  builder: (_, __) => const ComunidadScreen()),
          GoRoute(path: '/correspondencia', builder: (_, __) => const CorrespondenciaScreen()),
          GoRoute(path: '/finanzas', builder: (_, __) => const FinanzasScreen()),
        ],
      ),
    ],
  );
}
