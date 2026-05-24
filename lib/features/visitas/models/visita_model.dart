import 'package:flutter/material.dart';

enum TipoVisita { familiar, suministro, mudanza, trabajador }

class VisitaModel {
  final String id;
  final String nombre;
  final TipoVisita tipo;
  final String? placa;
  final String codigoSeguridad;
  final DateTime fechaCreacion;
  final DateTime fechaExpiracion;
  final String casaDestino;
  final bool yaIngreso;

  VisitaModel({
    required this.id,
    required this.nombre,
    required this.tipo,
    this.placa,
    required this.codigoSeguridad,
    required this.fechaCreacion,
    required this.fechaExpiracion,
    required this.casaDestino,
    this.yaIngreso = false,
  });

  bool get estaExpirado => DateTime.now().isAfter(fechaExpiracion);

  String get nombreTipo {
    switch (tipo) {
      case TipoVisita.familiar: return 'Visitante';
      case TipoVisita.suministro: return 'Camión de Suministro';
      case TipoVisita.mudanza: return 'Mudanza';
      case TipoVisita.trabajador: return 'Personal Externo';
    }
  }
}
