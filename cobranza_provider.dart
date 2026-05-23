// apps/mobile/lib/features/cobranza/providers/cobranza_provider.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/cache/cache_manager.dart';
import '../../../core/network/api_client.dart';
import '../models/cuota_model.dart';

part 'cobranza_provider.g.dart';

@riverpod
class CobranzaNotifier extends _$CobranzaNotifier {
  static const _cacheKey = 'estado_cuenta';
  static const _ttl      = 300; // 5 minutos

  @override
  Future<EstadoCuentaModel> build() async {
    return _cargar();
  }

  Future<EstadoCuentaModel> _cargar() async {
    // 1. Intentar caché local
    final cached = CacheManager.get<Map>(CacheBoxes.cuotas, _cacheKey);
    if (cached != null) {
      return EstadoCuentaModel.fromJson(Map<String, dynamic>.from(cached));
    }

    // 2. Llamar API
    final dio = ref.read(apiClientProvider);
    final res = await dio.get('/cobranza/estado-cuenta');
    final modelo = EstadoCuentaModel.fromJson(res.data);

    // 3. Guardar en caché
    await CacheManager.set(CacheBoxes.cuotas, _cacheKey, res.data, ttlSeconds: _ttl);

    return modelo;
  }

  Future<void> refrescar() async {
    await CacheManager.invalidate(CacheBoxes.cuotas, _cacheKey);
    state = const AsyncLoading();
    state = await AsyncValue.guard(_cargar);
  }

  /// Sube comprobante de pago — imagen desde cámara o galería
  Future<void> subirComprobante({
    required int cuotaId,
    required double monto,
    required XFile imagen,
  }) async {
    final dio = ref.read(apiClientProvider);

    final formData = FormData.fromMap({
      'cuotaId': cuotaId.toString(),
      'monto':   monto.toString(),
      'archivo': await MultipartFile.fromFile(
        imagen.path,
        filename: imagen.name,
      ),
    });

    await dio.post('/cobranza/pagar', data: formData);

    // Invalida caché para reflejar el nuevo pago
    await refrescar();
  }
}
