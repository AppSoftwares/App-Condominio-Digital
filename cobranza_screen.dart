// apps/mobile/lib/features/cobranza/screens/cobranza_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../models/cuota_model.dart';
import '../providers/cobranza_provider.dart';
import '../widgets/cuota_timeline_item.dart';
import '../widgets/subir_comprobante_sheet.dart';

class CobranzaScreen extends ConsumerWidget {
  const CobranzaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estadoAsync = ref.watch(cobranzaNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Cuotas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(cobranzaNotifierProvider.notifier).refrescar(),
          ),
        ],
      ),
      body: estadoAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorView(error: e.toString(), onRetry: () => ref.invalidate(cobranzaNotifierProvider)),
        data: (estado) => _CobranzaBody(estado: estado),
      ),
    );
  }
}

class _CobranzaBody extends ConsumerWidget {
  const _CobranzaBody({required this.estado});
  final EstadoCuentaModel estado;

  static final NumberFormat _fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final hasBanner = estado.esProntoPago && estado.diasRestantesProntoPago > 0;
    final headerCount = hasBanner ? 6 : 4;

    return RefreshIndicator(
      onRefresh: () => ref.read(cobranzaNotifierProvider.notifier).refrescar(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: headerCount + estado.cuotas.length,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _ResumenCard(estado: estado, fmt: _fmt);
          }
          if (index == 1) {
            return const SizedBox(height: 20);
          }

          if (hasBanner) {
            if (index == 2) {
              return _BannerProntoPago(dias: estado.diasRestantesProntoPago);
            }
            if (index == 3) {
              return const SizedBox(height: 20);
            }
            if (index == 4) {
              return Text('Historial de cuotas', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold));
            }
            if (index == 5) {
              return const SizedBox(height: 12);
            }
            final cuota = estado.cuotas[index - 6];
            return CuotaTimelineItem(
              cuota: cuota,
              onPagar: (cuota.estado == EstadoCuota.pendiente || cuota.estado == EstadoCuota.morosa)
                  ? () => _mostrarSubirComprobante(context, ref, cuota, estado.montoActual)
                  : null,
            );
          }

          if (index == 2) {
            return Text('Historial de cuotas', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold));
          }
          if (index == 3) {
            return const SizedBox(height: 12);
          }

          final cuota = estado.cuotas[index - 4];
          return CuotaTimelineItem(
            cuota: cuota,
            onPagar: (cuota.estado == EstadoCuota.pendiente || cuota.estado == EstadoCuota.morosa)
                ? () => _mostrarSubirComprobante(context, ref, cuota, estado.montoActual)
                : null,
          );
        },
      ),
    );
  }

  void _mostrarSubirComprobante(
    BuildContext context,
    WidgetRef ref,
    CuotaModel cuota,
    double monto,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SubirComprobanteSheet(
        cuota: cuota,
        monto: monto,
        onConfirmar: (imagen) async {
          Navigator.pop(context);
          try {
            await ref.read(cobranzaNotifierProvider.notifier).subirComprobante(
              cuotaId: cuota.id,
              monto: monto,
              imagen: imagen,
            );
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ Comprobante enviado. Pendiente de validación.'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
              );
            }
          }
        },
      ),
    );
  }
}

// ── Tarjeta de resumen ─────────────────────────────────────────
class _ResumenCard extends StatelessWidget {
  const _ResumenCard({required this.estado, required this.fmt});
  final EstadoCuentaModel  estado;
  final NumberFormat       fmt;

  @override
  Widget build(BuildContext context) {
    final theme     = Theme.of(context);
    final tieneDeuda = estado.totalDeuda > 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: tieneDeuda
              ? [Colors.red.shade700, Colors.red.shade500]
              : [const Color(0xFF1A6B3C), const Color(0xFF2E9E5B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tieneDeuda ? 'Deuda pendiente' : 'Al corriente ✓',
            style: theme.textTheme.labelLarge?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Text(
            tieneDeuda ? fmt.format(estado.totalDeuda) : fmt.format(0),
            style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white, fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _InfoChip(label: 'Cuota actual', valor: fmt.format(estado.montoActual)),
              _InfoChip(
                label: estado.esProntoPago ? 'Pronto pago' : 'Normal',
                valor: estado.esProntoPago ? '\$15.00' : '\$20.00',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.valor});
  final String label, valor;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
      Text(valor,  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
    ],
  );
}

// ── Banner pronto pago ─────────────────────────────────────────
class _BannerProntoPago extends StatelessWidget {
  const _BannerProntoPago({required this.dias});
  final int dias;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.amber.shade50,
      border: Border.all(color: Colors.amber.shade300),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Icon(Icons.timer_outlined, color: Colors.amber.shade700),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            '¡Pronto pago! Paga hoy y ahorra \$5.00. Te quedan $dias día${dias == 1 ? '' : 's'}.',
            style: TextStyle(color: Colors.amber.shade900, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    ),
  );
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, required this.onRetry});
  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.error_outline, size: 48, color: Colors.red),
        const SizedBox(height: 12),
        Text(error, textAlign: TextAlign.center),
        const SizedBox(height: 16),
        FilledButton(onPressed: onRetry, child: const Text('Reintentar')),
      ],
    ),
  );
}
