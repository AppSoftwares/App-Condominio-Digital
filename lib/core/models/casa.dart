class Casa {
  final String id;         // doc ID Firestore
  final int    conjuntoId; // ej: 14
  final int    numero;     // ej: 28  → muestra "14-28"
  final String propietario;
  final bool   alDia;      // estado de cuota
  final double saldoPendiente;

  const Casa({
    required this.id,
    required this.conjuntoId,
    required this.numero,
    required this.propietario,
    required this.alDia,
    this.saldoPendiente = 0.0,
  });

  String get codigo => '$conjuntoId-$numero';

  factory Casa.fromMap(Map<String, dynamic> map, String id) {
    return Casa(
      id: id,
      conjuntoId: map['conjuntoId'] ?? 0,
      numero: map['numero'] ?? 0,
      propietario: map['propietario'] ?? '',
      alDia: map['alDia'] ?? true,
      saldoPendiente: (map['saldoPendiente'] ?? 0.0).toDouble(),
    );
  }
}
