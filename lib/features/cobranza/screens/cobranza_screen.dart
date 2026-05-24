import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/conjunto_provider.dart';
import '../../../core/models/casa.dart';

class CobranzaScreen extends ConsumerWidget {
  const CobranzaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conjunto = ref.watch(conjuntoSeleccionadoProvider);
    
    if (conjunto == null) {
      return const Scaffold(
        body: Center(child: Text('Seleccione un conjunto en la pantalla de inicio')),
      );
    }

    final casasAsync = ref.watch(casasFiltroProvider(conjunto.id));
    final fmt = NumberFormat.currency(symbol: '\$');

    return Scaffold(
      appBar: AppBar(
        title: Text('Cobranza: ${conjunto.nombre}'),
        actions: [
          const Tooltip(
            message: 'Estado de cuenta por casa.\nActualizado diariamente.',
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.info_outline),
            ),
          )
        ],
      ),
      body: casasAsync.when(
        data: (casas) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: casas.length,
          itemBuilder: (context, index) => _CasaCobranzaTile(casa: casas[index], fmt: fmt),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, __) => _LocalCobranzaDemoView(fmt: fmt), // Fallback para demo
      ),
    );
  }
}

class _LocalCobranzaDemoView extends StatelessWidget {
  final NumberFormat fmt;
  const _LocalCobranzaDemoView({required this.fmt});

  @override
  Widget build(BuildContext context) {
    // Datos de ejemplo para la urbanización
    final casasDemo = [
      const Casa(id: '1', conjuntoId: 14, numero: 28, propietario: 'Luis Pérez', alDia: true),
      const Casa(id: '2', conjuntoId: 14, numero: 30, propietario: 'María García', alDia: false, saldoPendiente: 50.0),
      const Casa(id: '3', conjuntoId: 14, numero: 45, propietario: 'Juan Rodríguez', alDia: false, saldoPendiente: 150.0),
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: casasDemo.length,
      itemBuilder: (context, index) => _CasaCobranzaTile(casa: casasDemo[index], fmt: fmt),
    );
  }
}

class _CasaCobranzaTile extends StatelessWidget {
  final Casa casa;
  final NumberFormat fmt;
  const _CasaCobranzaTile({required this.casa, required this.fmt});

  @override
  Widget build(BuildContext context) {
    final mesesPendientes = (casa.saldoPendiente / 50).floor(); // Asumiendo cuota de 50

    return Card(
      child: ListTile(
        title: Row(
          children: [
            Text(casa.codigo, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Text(casa.propietario, style: const TextStyle(fontSize: 14)),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                const Text('Saldo: ', style: TextStyle(fontSize: 12)),
                Text(fmt.format(casa.saldoPendiente), 
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    color: casa.alDia ? Colors.green : Colors.red
                  )
                ),
                const Spacer(),
                const Tooltip(
                  message: 'Cuota mensual de mantenimiento.\nFecha límite: día 5 de cada mes.',
                  child: Icon(Icons.info_outline, size: 16, color: Colors.grey),
                )
              ],
            ),
          ],
        ),
        trailing: Chip(
          label: Text(casa.alDia ? 'AL DÍA' : '$mesesPendientes MESES', 
            style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)
          ),
          backgroundColor: _chipColor(mesesPendientes, casa.alDia),
        ),
      ),
    );
  }

  Color _chipColor(int meses, bool alDia) {
    if (alDia) return Colors.green;
    if (meses == 1) return Colors.orange;
    return Colors.red;
  }
}
