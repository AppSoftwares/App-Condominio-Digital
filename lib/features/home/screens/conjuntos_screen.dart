import 'package:flutter/material.dart';
import '../../../core/data/conjuntos_data.dart';

class ConjuntosScreen extends StatelessWidget {
  const ConjuntosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Conjuntos Residenciales')),
      body: ListView.builder(
        itemCount: conjuntosData.length,
        itemBuilder: (context, i) {
          final c = conjuntosData[i];
          return ListTile(
            title: Text(c.nombre),
            subtitle: Text('Etapa ${c.etapa} - ${c.totalCasas} casas'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navegar o seleccionar conjunto
            },
          );
        },
      ),
    );
  }
}
