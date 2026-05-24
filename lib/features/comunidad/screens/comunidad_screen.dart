import 'package:flutter/material.dart';
import '../../correspondencia/models/paquete_model.dart'; // Reutilizando el modelo de contacto

class ComunidadScreen extends StatelessWidget {
  const ComunidadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final contactos = [
      ContactoComunidad(id: '1', nombre: 'Juan Pérez', casa: '10-A', telefono: '+58 412 555 1234'),
      ContactoComunidad(id: '2', nombre: 'María García', casa: '14-71', telefono: '+58 424 111 2233'),
      ContactoComunidad(id: '3', nombre: 'Admin Residencia', casa: 'Oficina', telefono: '+58 212 999 0000'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Agenda de la Comunidad')),
      body: ListView.builder(
        itemCount: contactos.length,
        itemBuilder: (context, index) {
          final c = contactos[index];
          return ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(c.nombre),
            subtitle: Text('Casa: ${c.casa}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: const Icon(Icons.phone, color: Colors.green), onPressed: () {}),
                IconButton(icon: const Icon(Icons.message, color: Colors.blue), onPressed: () {}),
              ],
            ),
          );
        },
      ),
    );
  }
}
