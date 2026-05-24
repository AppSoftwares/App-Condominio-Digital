import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/conjunto_provider.dart';
import '../providers/bitacora_provider.dart';
import '../models/novedad_model.dart';

class BitacoraScreen extends ConsumerWidget {
  const BitacoraScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conjunto = ref.watch(conjuntoSeleccionadoProvider);
    
    if (conjunto == null) {
      return const Scaffold(
        body: Center(child: Text('Seleccione un conjunto en la pantalla de inicio')),
      );
    }

    final bitacoraAsync = ref.watch(bitacoraProvider(conjunto.id));

    return Scaffold(
      appBar: AppBar(
        title: Text('Bitácora: ${conjunto.nombre}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          )
        ],
      ),
      body: bitacoraAsync.when(
        data: (novedades) => ListView.builder(
          itemCount: novedades.length,
          itemBuilder: (context, index) => _NovedadTile(novedad: novedades[index]),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, __) => _LocalBitacoraView(), // Fallback a datos locales para demo
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFB5541A),
        onPressed: () => _mostrarDialogoNuevaNovedad(context, ref, conjunto.id),
        child: const Icon(Icons.add_comment, color: Colors.white),
      ),
    );
  }

  void _mostrarDialogoNuevaNovedad(BuildContext context, WidgetRef ref, int conjuntoId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => NuevaNovedadForm(conjuntoId: conjuntoId),
    );
  }
}

class _LocalBitacoraView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final novedades = ref.watch(bitacoraLocalProvider);
    return ListView.builder(
      itemCount: novedades.length,
      itemBuilder: (context, index) => _NovedadTile(novedad: novedades[index]),
    );
  }
}

class _NovedadTile extends StatelessWidget {
  final NovedadModel novedad;
  const _NovedadTile({required this.novedad});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM HH:mm');
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getColor(novedad.tipo),
          child: Icon(_getIcon(novedad.tipo), color: Colors.white, size: 20),
        ),
        title: Text(
          novedad.casaAfectada != null ? 'Casa ${novedad.casaAfectada}' : novedad.tipo.name.toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(novedad.descripcion),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Por: ${novedad.vigilanteId}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text(fmt.format(novedad.timestamp), style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getColor(CategoriaNovedad cat) {
    switch (cat) {
      case CategoriaNovedad.ingreso: return Colors.green;
      case CategoriaNovedad.incidente: return Colors.red;
      case CategoriaNovedad.personal: return Colors.blue;
      case CategoriaNovedad.novedad: return Colors.orange;
    }
  }

  IconData _getIcon(CategoriaNovedad cat) {
    switch (cat) {
      case CategoriaNovedad.ingreso: return Icons.login;
      case CategoriaNovedad.incidente: return Icons.warning_amber;
      case CategoriaNovedad.personal: return Icons.person_outline;
      case CategoriaNovedad.novedad: return Icons.info_outline;
    }
  }
}

class NuevaNovedadForm extends ConsumerStatefulWidget {
  final int conjuntoId;
  const NuevaNovedadForm({super.key, required this.conjuntoId});
  @override
  ConsumerState<NuevaNovedadForm> createState() => _NuevaNovedadFormState();
}

class _NuevaNovedadFormState extends ConsumerState<NuevaNovedadForm> {
  final _descController = TextEditingController();
  final _casaController = TextEditingController();
  CategoriaNovedad _cat = CategoriaNovedad.novedad;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Registrar Novedad', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          DropdownButtonFormField<CategoriaNovedad>(
            value: _cat,
            items: CategoriaNovedad.values.map((c) => DropdownMenuItem(value: c, child: Text(c.name.toUpperCase()))).toList(),
            onChanged: (v) => setState(() => _cat = v!),
            decoration: const InputDecoration(labelText: 'Tipo de Novedad'),
          ),
          TextField(controller: _casaController, decoration: const InputDecoration(labelText: 'Casa Afectada (Opcional, ej: 14-28)')),
          TextField(controller: _descController, decoration: const InputDecoration(labelText: 'Descripción'), maxLines: 3),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB5541A), foregroundColor: Colors.white),
            onPressed: () {
              ref.read(bitacoraLocalProvider.notifier).agregarNovedad(
                NovedadModel(
                  id: DateTime.now().toString(),
                  descripcion: _descController.text,
                  tipo: _cat,
                  timestamp: DateTime.now(),
                  conjuntoId: widget.conjuntoId,
                  vigilanteId: 'Vigilante Actual',
                  casaAfectada: _casaController.text.isNotEmpty ? _casaController.text : null,
                )
              );
              Navigator.pop(context);
            },
            child: const Text('Guardar en Bitácora'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
