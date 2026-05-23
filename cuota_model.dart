// apps/mobile/lib/features/cobranza/models/cuota_model.dart

enum EstadoCuota { pendiente, pagada, morosa, enConvenio }
enum EstadoPago  { pendienteValidacion, aprobado, rechazado }

class PagoModel {
  final int       id;
  final double    monto;
  final String    comprobanteUrl;
  final EstadoPago estado;
  final DateTime  fechaPago;
  final DateTime? validadoEn;
  final String?   notas;

  const PagoModel({
    required this.id,
    required this.monto,
    required this.comprobanteUrl,
    required this.estado,
    required this.fechaPago,
    this.validadoEn,
    this.notas,
  });

  factory PagoModel.fromJson(Map<String, dynamic> j) => PagoModel(
    id:             j['id'],
    monto:          (j['monto'] as num).toDouble(),
    comprobanteUrl: j['comprobanteUrl'],
    estado:         _parseEstadoPago(j['estado']),
    fechaPago:      DateTime.parse(j['fechaPago']),
    validadoEn:     j['validadoEn'] != null ? DateTime.parse(j['validadoEn']) : null,
    notas:          j['notas'],
  );

  static EstadoPago _parseEstadoPago(String s) => switch (s) {
    'APROBADO'             => EstadoPago.aprobado,
    'RECHAZADO'            => EstadoPago.rechazado,
    _                      => EstadoPago.pendienteValidacion,
  };
}

class CuotaModel {
  final int          id;
  final int          mes;
  final int          anio;
  final double       monto;
  final EstadoCuota  estado;
  final PagoModel?   pago;

  const CuotaModel({
    required this.id,
    required this.mes,
    required this.anio,
    required this.monto,
    required this.estado,
    this.pago,
  });

  factory CuotaModel.fromJson(Map<String, dynamic> j) => CuotaModel(
    id:     j['id'],
    mes:    j['mes'],
    anio:   j['anio'],
    monto:  (j['monto'] as num).toDouble(),
    estado: _parseEstado(j['estado']),
    pago:   j['pago'] != null ? PagoModel.fromJson(j['pago']) : null,
  );

  static EstadoCuota _parseEstado(String s) => switch (s) {
    'PAGADA'      => EstadoCuota.pagada,
    'MOROSA'      => EstadoCuota.morosa,
    'EN_CONVENIO' => EstadoCuota.enConvenio,
    _             => EstadoCuota.pendiente,
  };

  String get nombreMes => const [
    '', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
  ][mes];
}

class EstadoCuentaModel {
  final List<CuotaModel> cuotas;
  final double           totalDeuda;
  final double           montoActual;
  final bool             esProntoPago;
  final int              diasRestantesProntoPago;

  const EstadoCuentaModel({
    required this.cuotas,
    required this.totalDeuda,
    required this.montoActual,
    required this.esProntoPago,
    required this.diasRestantesProntoPago,
  });

  factory EstadoCuentaModel.fromJson(Map<String, dynamic> j) => EstadoCuentaModel(
    cuotas:                  (j['cuotas'] as List).map((e) => CuotaModel.fromJson(e)).toList(),
    totalDeuda:              (j['totalDeuda'] as num).toDouble(),
    montoActual:             (j['montoActual'] as num).toDouble(),
    esProntoPago:            j['esProntoPago'] ?? false,
    diasRestantesProntoPago: j['diasRestantesProntoPago'] ?? 0,
  );
}
