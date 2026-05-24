import 'package:flutter/material.dart';
import '../widgets/conjunto_selector.dart';

class HomeContentScreen extends StatelessWidget {
  const HomeContentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHero(),
            const ConjuntoSelector(),
            const SizedBox(height: 20),
            // Aquí se podrían añadir más secciones como resumen de deudas, etc.
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(Icons.home_work, size: 48, color: Color(0xFFB5541A)),
                      SizedBox(height: 12),
                      Text(
                        'Bienvenido a su Gestión de Condominio',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Seleccione su conjunto arriba para ver información específica.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHero() => Container(
    height: 180,
    width: double.infinity,
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFFB5541A), Color(0xFFD4A843)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      // Nota: Asegúrate de tener la imagen en assets
      /*
      image: DecorationImage(
        image: AssetImage('assets/images/portada_lagunita.jpg'),
        fit: BoxFit.cover,
        colorFilter: ColorFilter.mode(
          Color(0x66000000), BlendMode.darken,
        ),
      ),
      */
    ),
    child: const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('CAMINOS DE LA LAGUNITA',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        SizedBox(height: 4),
        Text('Gestión de Condominio',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ],
    ),
  );
}
