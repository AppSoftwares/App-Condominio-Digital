// apps/mobile/lib/features/auth/providers/auth_provider.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/api/api_client.dart';
import '../../../core/cache/cache_manager.dart';
import '../models/usuario_model.dart';

part 'auth_provider.g.dart';

const _storage = FlutterSecureStorage();
final _googleSignIn = GoogleSignIn();

class AuthState {
  final bool isLoggedIn;
  final UsuarioModel? usuario;

  const AuthState({required this.isLoggedIn, this.usuario});
}

@riverpod
class AuthStateNotifier extends _$AuthStateNotifier {
  @override
  Future<AuthState> build() async {
    final token = await _storage.read(key: 'access_token');

    // Si hay token, lo consideramos logueado inmediatamente para no bloquear el inicio
    if (token != null) {
      final cached = CacheManager.get<Map>(CacheBoxes.auth, 'usuario');
      if (cached != null) {
        return AuthState(isLoggedIn: true, usuario: UsuarioModel.fromJson(Map<String, dynamic>.from(cached)));
      }
      // Si el caché expiró pero hay token, seguimos logueados pero sin datos de usuario
      return const AuthState(isLoggedIn: true, usuario: null);
    }

    return const AuthState(isLoggedIn: false);
  }

  Future<void> login(String email, String password) async {
    final dio = ref.read(apiClientProvider);
    final res = await dio.post('/auth/login', data: {'email': email, 'password': password});
    await _saveAuthData(res.data);
  }

  Future<void> loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final dio = ref.read(apiClientProvider);
      final res = await dio.post('/auth/google', data: {
        'idToken': googleAuth.idToken,
      });

      await _saveAuthData(res.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _saveAuthData(Map<String, dynamic> data) async {
    final accessToken  = data['accessToken'] as String;
    final refreshToken = data['refreshToken'] as String;
    final usuario = UsuarioModel.fromJson(data['usuario']);

    await _storage.write(key: 'access_token', value: accessToken);
    await _storage.write(key: 'refresh_token', value: refreshToken);

    // Cache del usuario por 30 días para que la sesión sea persistente y duradera
    await CacheManager.set(CacheBoxes.auth, 'usuario', data['usuario'], ttlSeconds: 2592000);

    state = AsyncData(AuthState(isLoggedIn: true, usuario: usuario));
  }

  Future<void> logout() async {
    final refreshToken = await _storage.read(key: 'refresh_token');
    try {
      final dio = ref.read(apiClientProvider);
      await dio.post('/auth/logout', data: {'refreshToken': refreshToken});
      await _googleSignIn.signOut();
    } catch (_) {}

    await _storage.deleteAll();
    await CacheManager.clearAll();

    state = const AsyncData(AuthState(isLoggedIn: false));
  }
}

// Alias cómodo para los consumers
final authStateProvider = authStateNotifierProvider;
