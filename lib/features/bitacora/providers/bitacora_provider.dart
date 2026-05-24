import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/novedad_model.dart';

final bitacoraProvider = StreamProvider.family<List<NovedadModel>, int>((ref, conjuntoId) {
  return FirebaseFirestore.instance
      .collection('bitacora')
      .where('conjuntoId', isEqualTo: conjuntoId)
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) => NovedadModel.fromMap(d.data(), d.id)).toList());
});

// Mantengo el notifier para datos locales si no hay firebase configurado aún
final bitacoraLocalProvider = StateNotifierProvider<BitacoraNotifier, List<NovedadModel>>((ref) {
  return BitacoraNotifier();
});

class BitacoraNotifier extends StateNotifier<List<NovedadModel>> {
  BitacoraNotifier() : super([]) {
    state = [
      NovedadModel(
        id: '1',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        tipo: CategoriaNovedad.ingreso,
        descripcion: 'Jesus Perez (Jardinero) ingresó para mantenimiento de áreas verdes.',
        conjuntoId: 14,
        vigilanteId: 'v1',
      ),
      NovedadModel(
        id: '2',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        tipo: CategoriaNovedad.incidente,
        descripcion: 'Perro de la casa 12 rompió maceta decorativa en pasillo B.',
        casaAfectada: '14-12',
        conjuntoId: 14,
        vigilanteId: 'v2',
      ),
    ];
  }

  void agregarNovedad(NovedadModel novedad) {
    state = [novedad, ...state];
  }
}
