import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../bitacora/models/novedad_model.dart'; // Reutilizando el modelo definido antes

final reportesMantenimientoProvider = StateNotifierProvider<MantenimientoNotifier, List<ReporteMantenimientoModel>>((ref) {
  return MantenimientoNotifier();
});

class MantenimientoNotifier extends StateNotifier<List<ReporteMantenimientoModel>> {
  MantenimientoNotifier() : super([]) {
    state = [
      ReporteMantenimientoModel(
        id: '1',
        titulo: 'Gotera en techo bohío',
        ubicacion: 'Área social delantera',
        descripcion: 'Se filtra agua cuando llueve fuerte, requiere sellador.',
        estado: EstadoReporte.pendiente,
        fechaReporte: DateTime.now().subtract(const Duration(days: 2)),
      ),
      ReporteMantenimientoModel(
        id: '2',
        titulo: 'Lámpara fundida',
        ubicacion: 'Pasillo entrada 4',
        descripcion: 'La luminaria LED parpadea y luego se apaga.',
        estado: EstadoReporte.atendida,
        fechaReporte: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];
  }

  void crearReporte(ReporteMantenimientoModel reporte) {
    state = [reporte, ...state];
  }

  void actualizarEstado(String id, EstadoReporte nuevoEstado) {
    state = [
      for (final r in state)
        if (r.id == id)
          ReporteMantenimientoModel(
            id: r.id,
            titulo: r.titulo,
            ubicacion: r.ubicacion,
            descripcion: r.descripcion,
            estado: nuevoEstado,
            fechaReporte: r.fechaReporte,
            fotoUrl: r.fotoUrl,
          )
        else
          r
    ];
  }
}
