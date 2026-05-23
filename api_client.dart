// apps/mobile/lib/core/network/api_client.dart
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'api_client.g.dart';

const _storage = FlutterSecureStorage();

@riverpod
Dio apiClient(ApiClientRef ref) {
  final dio = Dio(BaseOptions(
    baseUrl: dotenv.env['API_URL'] ?? 'http://10.0.2.2:4000', // Android emulator → localhost
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
    headers: {'Content-Type': 'application/json'},
  ));

  dio.interceptors.add(_AuthInterceptor(dio));
  return dio;
}

class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(this._dio);
  final Dio _dio;

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.read(key: 'access_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    // Auto-renovar token si expiró (401)
    if (err.response?.statusCode == 401) {
      final refreshToken = await _storage.read(key: 'refresh_token');
      if (refreshToken == null) return handler.next(err);

      try {
        final res = await _dio.post('/auth/refresh', data: {'refreshToken': refreshToken});
        final newToken = res.data['accessToken'] as String;
        await _storage.write(key: 'access_token', value: newToken);

        // Reintentar la petición original con el nuevo token
        err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
        final retry = await _dio.fetch(err.requestOptions);
        return handler.resolve(retry);
      } catch (_) {
        // Refresh falló → forzar logout
        await _storage.deleteAll();
        return handler.next(err);
      }
    }
    handler.next(err);
  }
}
