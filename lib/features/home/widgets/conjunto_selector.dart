import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data/conjuntos_data.dart';
import '../../../core/providers/conjunto_provider.dart';

class ConjuntoSelector extends ConsumerWidget {
  const ConjuntoSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seleccionado = ref.watch(conjuntoSeleccionadoProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(12),
          child: Text('Selecciona tu conjunto',
              style: TextStyle(fontWeight: FontWeight.w600)),
        ),
        SizedBox(
          height: 50,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: conjuntosData.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final c = conjuntosData[i];
              final isSelected = seleccionado?.id == c.id;
              return ChoiceChip(
                label: Text('${c.nombre} (Etapa ${c.etapa})'),
                selected: isSelected,
                selectedColor: const Color(0xFFB5541A),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
                onSelected: (_) => ref
                    .read(conjuntoSeleccionadoProvider.notifier)
                    .state = c,
              );
            },
          ),
        ),
      ],
    );
  }
}
