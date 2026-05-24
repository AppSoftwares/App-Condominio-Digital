import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../bitacora/models/novedad_model.dart';
import '../providers/mantenimiento_provider.dart';

class MantenimientoScreen extends ConsumerWidget {
  const MantenimientoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportes = ref.watch(reportesMantenimientoProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Reportes de Mantenimiento')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: reportes.length,
        itemBuilder: (context, index) {
          final reporte = reportes[index];
          return Card(
            child: ListTile(
              leading: Icon(
                reporte.estado == EstadoReporte.atendida ? Icons.check_circle : Icons.pending,
                color: _getColor(reporte.estado),
              ),
              title: Text(reporte.titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${reporte.ubicacion}\n${reporte.descripcion}'),
              isThreeLine: true,
              trailing: Chip(
                label: Text(reporte.estado.name, style: const TextStyle(fontSize: 10)),
                backgroundColor: _getColor(reporte.estado).withOpacity(0.1),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarDialogoNuevoReporte(context, ref),
        child: const Icon(Icons.report_problem_outlined),
      ),
    );
  }

  Color _getColor(EstadoReporte estado) {
    switch (estado) {
      case EstadoReporte.pendiente: return Colors.red;
      case EstadoReporte.revisada: return Colors.orange;
      case EstadoReporte.atendida: return Colors.green;
    }
  }

  void _mostrarDialogoNuevoReporte(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const NuevoReporteForm(),
    );
  }
}

class NuevoReporteForm extends ConsumerStatefulWidget {
  const NuevoReporteForm({super.key});
  @override
  ConsumerState<NuevoReporteForm> createState() => _NuevoReporteFormState();
}

class _NuevoReporteFormState extends ConsumerState<NuevoReporteForm> {
  final _titulo = TextEditingController();
  final _ubicacion = TextEditingController();
  final _desc = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Nuevo Reporte al Administrador', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          TextField(controller: _titulo, decoration: const InputDecoration(labelText: '¿Qué sucede?')),
          TextField(controller: _ubicacion, decoration: const InputDecoration(labelText: 'Ubicación (Ej: Pasillo A)')),
          TextField(controller: _desc, decoration: const InputDecoration(labelText: 'Descripción detallada'), maxLines: 2),
          const SizedBox(height: 10),
          OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.camera_alt), label: const Text('Adjuntar Foto')),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              ref.read(reportesMantenimientoProvider.notifier).crearReporte(
                ReporteMantenimientoModel(
                  id: DateTime.now().toString(),
                  titulo: _titulo.text,
                  ubicacion: _ubicacion.text,
                  descripcion: _desc.text,
                  estado: EstadoReporte.pendiente,
                  fechaReporte: DateTime.now(),
                )
              );
              Navigator.pop(context);
            },
            child: const Text('Enviar Reporte'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
