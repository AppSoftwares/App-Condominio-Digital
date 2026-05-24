enum CategoriaNovedad { incidente, ingreso, personal, novedad }

class NovedadModel {
  final String id;
  final DateTime timestamp;
  final CategoriaNovedad tipo;
  final String descripcion;
  final String? casaAfectada; // Ej: "14-28"
  final int conjuntoId;
  final String vigilanteId;
  final String? imagenUrl;

  NovedadModel({
    required this.id,
    required this.timestamp,
    required this.tipo,
    required this.descripcion,
    this.casaAfectada,
    required this.conjuntoId,
    required this.vigilanteId,
    this.imagenUrl,
  });

  factory NovedadModel.fromMap(Map<String, dynamic> map, String id) {
    return NovedadModel(
      id: id,
      timestamp: (map['timestamp'] as dynamic)?.toDate() ?? DateTime.now(),
      tipo: CategoriaNovedad.values.firstWhere((e) => e.name == map['tipo'], orElse: () => CategoriaNovedad.novedad),
      descripcion: map['descripcion'] ?? '',
      casaAfectada: map['casaAfectada'],
      conjuntoId: map['conjuntoId'] ?? 0,
      vigilanteId: map['vigilanteId'] ?? '',
      imagenUrl: map['imagenUrl'],
    );
  }
}

enum EstadoReporte { pendiente, revisada, atendida }

class ReporteMantenimientoModel {
  final String id;
  final String titulo;
  final String ubicacion;
  final String descripcion;
  final EstadoReporte estado;
  final String? fotoUrl;
  final DateTime fechaReporte;

  ReporteMantenimientoModel({
    required this.id,
    required this.titulo,
    required this.ubicacion,
    required this.descripcion,
    required this.estado,
    this.fotoUrl,
    required this.fechaReporte,
  });
}
