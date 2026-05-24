// apps/mobile/lib/core/cache/cache_manager.dart
import 'package:hive_flutter/hive_flutter.dart';

/// Nombres de boxes (tablas locales en Hive)
class CacheBoxes {
  static const String auth       = 'auth';
  static const String finanzas   = 'finanzas';
  static const String cuotas     = 'cuotas';
  static const String reservas   = 'reservas';
  static const String mensajes   = 'mensajes';
  static const String ubicacion  = 'ubicacion';  // árbol urbanización
  static const String votaciones = 'votaciones';
}

class CacheManager {
  static Future<void> init() async {
    await Hive.openBox(CacheBoxes.auth);
    await Hive.openBox(CacheBoxes.finanzas);
    await Hive.openBox(CacheBoxes.cuotas);
    await Hive.openBox(CacheBoxes.reservas);
    await Hive.openBox(CacheBoxes.mensajes);
    await Hive.openBox(CacheBoxes.ubicacion);
    await Hive.openBox(CacheBoxes.votaciones);
  }

  /// Guarda datos con TTL (tiempo de vida en segundos)
  static Future<void> set(String boxName, String key, dynamic data, {int ttlSeconds = 300}) async {
    final box = Hive.box(boxName);
    await box.put(key, {
      'data': data,
      'expiresAt': DateTime.now().add(Duration(seconds: ttlSeconds)).millisecondsSinceEpoch,
    });
  }

  /// Retorna datos si no han expirado, null si expiraron
  static T? get<T>(String boxName, String key) {
    final box = Hive.box(boxName);
    final entry = box.get(key) as Map?;
    if (entry == null) return null;

    final expiresAt = entry['expiresAt'] as int;
    if (DateTime.now().millisecondsSinceEpoch > expiresAt) {
      box.delete(key); // limpiar entrada expirada
      return null;
    }
    return entry['data'] as T?;
  }

  static Future<void> invalidate(String boxName, String key) async {
    await Hive.box(boxName).delete(key);
  }

  static Future<void> clearBox(String boxName) async {
    await Hive.box(boxName).clear();
  }

  static Future<void> clearAll() async {
    await Hive.box(CacheBoxes.auth).clear();
    // ... repite para otros boxes si necesitas un logout total
  }
}
