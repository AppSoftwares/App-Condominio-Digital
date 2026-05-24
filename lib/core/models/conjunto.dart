class Conjunto {
  final int    id;       // ej: 14 (Las Huertas)
  final String nombre;   // ej: "Las Huertas"
  final int    etapa;    // 1–4
  final int    totalCasas;

  const Conjunto({
    required this.id,
    required this.nombre,
    required this.etapa,
    required this.totalCasas,
  });

  /// Casa número interna → código visible "14-28"
  String codigoCasa(int numeroCasa) => '$id-$numeroCasa';
}
