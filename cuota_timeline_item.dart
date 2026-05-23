// apps/mobile/lib/features/cobranza/widgets/cuota_timeline_item.dart
import 'package:flutter/material.dart';

import '../models/cuota_model.dart';

class CuotaTimelineItem extends StatelessWidget {
  const CuotaTimelineItem({
    super.key,
    required this.cuota,
    this.onPagar,
  });

  final CuotaModel  cuota;
  final VoidCallback? onPagar;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Línea del timeline ──────────────────────────
          SizedBox(
            width: 40,
            child: Column(
              children: [
                _EstadoIndicador(estado: cuota.estado),
                Expanded(child: Container(width: 2, color: Colors.grey.shade200)),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // ── Contenido ───────────────────────────────────
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border.all(color: _borderColor),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${cuota.nombreMes} ${cuota.anio}',
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      _EstadoBadge(estado: cuota.estado),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '\$${cuota.monto.toStringAsFixed(2)}',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // Detalles del pago si existe
                  if (cuota.pago != null) ...[
                    const SizedBox(height: 8),
                    _DetallePago(pago: cuota.pago!),
                  ],

                  // Botón pagar
                  if (onPagar != null) ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: onPagar,
                        icon: const Icon(Icons.upload_file, size: 18),
                        label: const Text('Subir comprobante'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color get _borderColor => switch (cuota.estado) {
    EstadoCuota.pagada     => Colors.green.shade200,
    EstadoCuota.morosa     => Colors.red.shade200,
    EstadoCuota.enConvenio => Colors.orange.shade200,
    EstadoCuota.pendiente  => Colors.grey.shade200,
  };
}

class _EstadoIndicador extends StatelessWidget {
  const _EstadoIndicador({required this.estado});
  final EstadoCuota estado;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (estado) {
      EstadoCuota.pagada     => (Icons.check_circle, Colors.green),
      EstadoCuota.morosa     => (Icons.cancel,        Colors.red),
      EstadoCuota.enConvenio => (Icons.handshake,     Colors.orange),
      EstadoCuota.pendiente  => (Icons.radio_button_unchecked, Colors.grey),
    };
    return Icon(icon, color: color, size: 24);
  }
}

class _EstadoBadge extends StatelessWidget {
  const _EstadoBadge({required this.estado});
  final EstadoCuota estado;

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (estado) {
      EstadoCuota.pagada     => ('Pagada',      Colors.green.shade100,  Colors.green.shade800),
      EstadoCuota.morosa     => ('Morosa',      Colors.red.shade100,    Colors.red.shade800),
      EstadoCuota.enConvenio => ('Convenio',    Colors.orange.shade100, Colors.orange.shade800),
      EstadoCuota.pendiente  => ('Pendiente',   Colors.grey.shade100,   Colors.grey.shade700),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

class _DetallePago extends StatelessWidget {
  const _DetallePago({required this.pago});
  final PagoModel pago;

  @override
  Widget build(BuildContext context) {
    final (icon, color, texto) = switch (pago.estado) {
      EstadoPago.aprobado            => (Icons.verified, Colors.green, 'Pago verificado'),
      EstadoPago.rechazado           => (Icons.error_outline, Colors.red, 'Pago rechazado'),
      EstadoPago.pendienteValidacion => (Icons.hourglass_empty, Colors.orange, 'En revisión'),
    };
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(texto, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500)),
        if (pago.notas != null) ...[
          const SizedBox(width: 8),
          Flexible(child: Text('· ${pago.notas}', style: const TextStyle(fontSize: 11, color: Colors.grey))),
        ],
      ],
    );
  }
}
