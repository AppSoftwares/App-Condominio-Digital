import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/conjunto_provider.dart';
import '../models/visita_model.dart';

enum TipoVisitaEnum { normal, mudanza, proveedor }

class RegistrarVisitaScreen extends ConsumerStatefulWidget {
  const RegistrarVisitaScreen({super.key});

  @override
  ConsumerState<RegistrarVisitaScreen> createState() => _RegistrarVisitaScreenState();
}

class _RegistrarVisitaScreenState extends ConsumerState<RegistrarVisitaScreen> {
  final _formKey = GlobalKey<FormState>();
  String _nombre = '';
  String _placa = '';
  String _casaNumero = '';
  TipoVisitaEnum _tipoSeleccionado = TipoVisitaEnum.normal;

  String _generarCodigo(String casaCodigo) {
    final ahora = DateTime.now();
    // código válido hasta las próximas 12h en punto (12:00 o 24:00)
    final expira = ahora.hour < 12
        ? DateTime(ahora.year, ahora.month, ahora.day, 12)
        : DateTime(ahora.year, ahora.month, ahora.day, 24);
    
    final hash = (casaCodigo + expira.millisecondsSinceEpoch.toString())
        .hashCode
        .abs()
        % 999999;
    return hash.toString().padLeft(6, '0');
  }

  void _guardar() {
    final conjunto = ref.read(conjuntoSeleccionadoProvider);
    if (conjunto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, seleccione un conjunto en la pantalla de inicio.')),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      final casaCodigo = '${conjunto.id}-$_casaNumero';
      final codigo = _generarCodigo(casaCodigo);
      final expira = DateTime.now().hour < 12
          ? DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 12)
          : DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 24);

      _mostrarCodigoGenerado(codigo, casaCodigo, expira);
    }
  }

  void _mostrarCodigoGenerado(String codigo, String casa, DateTime expira) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Código de Acceso'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Casa: $casa', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text('Código de seguridad (Válido 12h):'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F0E8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFB5541A), width: 2),
              ),
              child: Text(
                codigo,
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 8),
              ),
            ),
            const SizedBox(height: 10),
            Text('Expira hoy a las: ${expira.hour}:00', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final conjunto = ref.watch(conjuntoSeleccionadoProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Visita')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (conjunto != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text('Conjunto: ${conjunto.nombre}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFB5541A))),
              ),
            const Text('Tipo de visita', style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButtonFormField<TipoVisitaEnum>(
              value: _tipoSeleccionado,
              items: TipoVisitaEnum.values.map((t) => DropdownMenuItem(
                value: t,
                child: Text(t.name.toUpperCase()),
              )).toList(),
              onChanged: (val) => setState(() => _tipoSeleccionado = val!),
            ),
            const SizedBox(height: 20),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Nombre del Visitante / Proveedor'),
              validator: (val) => val!.isEmpty ? 'Requerido' : null,
              onSaved: (val) => _nombre = val!,
            ),
            const SizedBox(height: 20),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Número de Casa (ej: 28)'),
              keyboardType: TextInputType.number,
              validator: (val) => val!.isEmpty ? 'Requerido' : null,
              onSaved: (val) => _casaNumero = val!,
            ),
            const SizedBox(height: 20),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Placa del Vehículo (Opcional)'),
              onSaved: (val) => _placa = val!,
            ),
            const SizedBox(height: 40),
            FilledButton.icon(
              onPressed: _guardar,
              icon: const Icon(Icons.qr_code),
              label: const Text('Generar Código de Acceso'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: const Color(0xFFB5541A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
