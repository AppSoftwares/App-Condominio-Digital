import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/conjunto.dart';
import '../models/casa.dart';

final conjuntoSeleccionadoProvider = StateProvider<Conjunto?>((ref) => null);

final casasFiltroProvider = StreamProvider.family<List<Casa>, int>(
  (ref, conjuntoId) => FirebaseFirestore.instance
      .collection('casas')
      .where('conjuntoId', isEqualTo: conjuntoId)
      .orderBy('numero')
      .snapshots()
      .map((s) => s.docs.map((d) => Casa.fromMap(d.data(), d.id)).toList()),
);
