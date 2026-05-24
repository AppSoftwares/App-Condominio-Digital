enum EstadoPaquete { esperado, enRecibidor, entregado }

class PaqueteModel {
  final String id;
  final String propietarioId;
  final String casa;
  final String descripcion; // Ej: "Caja de Amazon", "Sobre de banco"
  final EstadoPaquete estado;
  final DateTime fechaRegistro;
  final DateTime? fechaEntrega;

  PaqueteModel({
    required this.id,
    required this.propietarioId,
    required this.casa,
    required this.descripcion,
    required this.estado,
    required this.fechaRegistro,
    this.fechaEntrega,
  });
}

class ContactoComunidad {
  final String id;
  final String nombre;
  final String casa;
  final String telefono;
  final String? urlAvatar;

  ContactoComunidad({
    required this.id,
    required this.nombre,
    required this.casa,
    required this.telefono,
    this.urlAvatar,
  });
}
