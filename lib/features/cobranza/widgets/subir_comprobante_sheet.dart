// apps/mobile/lib/features/cobranza/widgets/subir_comprobante_sheet.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../finanzas/models/cuota_model.dart';

class SubirComprobanteSheet extends StatefulWidget {
  const SubirComprobanteSheet({
    super.key,
    required this.cuota,
    required this.monto,
    required this.onConfirmar,
  });

  final CuotaModel                   cuota;
  final double                       monto;
  final Future<void> Function(XFile) onConfirmar;

  @override
  State<SubirComprobanteSheet> createState() => _SubirComprobanteSheetState();
}

class _SubirComprobanteSheetState extends State<SubirComprobanteSheet> {
  XFile?  _imagen;
  bool    _enviando = false;
  final   _picker   = ImagePicker();

  Future<void> _seleccionar(ImageSource fuente) async {
    final img = await _picker.pickImage(
      source: fuente,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    if (img != null) setState(() => _imagen = img);
  }

  Future<void> _confirmar() async {
    if (_imagen == null) return;
    setState(() => _enviando = true);
    await widget.onConfirmar(_imagen!);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),

          Text('Subir comprobante de pago', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            'Para validar tu pago de ${widget.cuota.nombreMes}, por favor adjunta una foto legible del comprobante de transferencia o depósito.',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'Monto a validar: \$${widget.monto.toStringAsFixed(2)}',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.primaryColor, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Preview de imagen
          if (_imagen != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(File(_imagen!.path), height: 200, fit: BoxFit.cover),
            )
          else
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image_outlined, size: 48, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('Sin imagen seleccionada', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // Botones de fuente
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _enviando ? null : () => _seleccionar(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Cámara'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _enviando ? null : () => _seleccionar(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Galería'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Confirmar
          FilledButton(
            onPressed: (_imagen == null || _enviando) ? null : _confirmar,
            style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
            child: _enviando
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Enviar comprobante', style: TextStyle(fontSize: 16)),
          ),

          const SizedBox(height: 8),
          Text(
            'El administrador validará tu pago en las próximas 24 h.',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
