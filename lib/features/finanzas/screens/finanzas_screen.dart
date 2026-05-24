import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FinanzasScreen extends StatelessWidget {
  const FinanzasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fmt = NumberFormat.currency(symbol: '\$');

    final gastosAdmin = [
      {'concepto': 'Compra de bolsas negras (basureros)', 'monto': 45.50, 'fecha': '12 Oct'},
      {'concepto': 'Cloro y desinfectante áreas sociales', 'monto': 120.00, 'fecha': '10 Oct'},
      {'concepto': 'Reparación bomba de agua principal', 'monto': 850.00, 'fecha': '05 Oct'},
      {'concepto': 'Pago servicio jardinería mensual', 'monto': 300.00, 'fecha': '01 Oct'},
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildBalanceCard(theme, fmt),
        const SizedBox(height: 24),
        Text('Gastos Administrativos y Operativos', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...gastosAdmin.map((gasto) => Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
          child: ListTile(
            leading: const Icon(Icons.shopping_cart_outlined, color: Colors.blue),
            title: Text(gasto['concepto'] as String),
            subtitle: Text(gasto['fecha'] as String),
            trailing: Text(fmt.format(gasto['monto']), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
          ),
        )),
      ],
    );
  }

  Widget _buildBalanceCard(ThemeData theme, NumberFormat fmt) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A6B3C),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Fondo de Reserva Total', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          Text(fmt.format(12450.80), style: theme.textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildMiniStat('Ingresos Mes', fmt.format(3200), Colors.green.shade200),
              const Spacer(),
              _buildMiniStat('Egresos Mes', fmt.format(1315.50), Colors.red.shade200),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }
}
