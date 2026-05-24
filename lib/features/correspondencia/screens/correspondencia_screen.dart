import 'package:flutter/material.dart';
import '../models/paquete_model.dart';

class CorrespondenciaScreen extends StatelessWidget {
  const CorrespondenciaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final paquetes = [
      PaqueteModel(
        id: '1',
        propietarioId: 'u1',
        casa: '14-71',
        descripcion: 'Paquete de Amazon (Caja mediana)',
        estado: EstadoPaquete.enRecibidor,
        fechaRegistro: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      PaqueteModel(
        id: '2',
        propietarioId: 'u1',
        casa: '14-71',
        descripcion: 'Sobre de correspondencia bancaria',
        estado: EstadoPaquete.entregado,
        fechaRegistro: DateTime.now().subtract(const Duration(days: 1)),
        fechaEntrega: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Paquetería y Correspondencia')),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue),
                SizedBox(width: 12),
                Expanded(child: Text('Cuando llegue un paquete a tu nombre, recibirás una notificación push inmediatamente.')),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: paquetes.length,
              itemBuilder: (context, index) {
                final pkg = paquetes[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: Icon(
                      pkg.estado == EstadoPaquete.enRecibidor ? Icons.inventory_2 : Icons.mark_email_read,
                      color: pkg.estado == EstadoPaquete.enRecibidor ? Colors.orange : Colors.green,
                    ),
                    title: Text(pkg.descripcion),
                    subtitle: Text(
                      pkg.estado == EstadoPaquete.enRecibidor 
                        ? 'Llegó hoy a las ${pkg.fechaRegistro.hour}:${pkg.fechaRegistro.minute}'
                        : 'Entregado el ${pkg.fechaEntrega?.day}/${pkg.fechaEntrega?.month}'
                    ),
                    trailing: pkg.estado == EstadoPaquete.enRecibidor 
                      ? const Chip(label: Text('En Garita', style: TextStyle(fontSize: 10)))
                      : const Icon(Icons.check, color: Colors.green),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        label: const Text('Esperando Paquete'),
        icon: const Icon(Icons.add_alert),
      ),
    );
  }
}
