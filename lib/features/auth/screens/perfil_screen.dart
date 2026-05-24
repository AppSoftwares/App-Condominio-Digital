import 'package:flutter/material.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi Perfil')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Center(
            child: CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 50),
            ),
          ),
          const SizedBox(height: 20),
          const ListTile(
            title: Text('Nombre'),
            subtitle: Text('Residente Casa 14-71'),
            leading: Icon(Icons.person_outline),
          ),
          const ListTile(
            title: Text('Correo'),
            subtitle: Text('propietario@condominio.com'),
            leading: Icon(Icons.email_outlined),
          ),
          const Divider(),
          ListTile(
            title: const Text('Cambiar Contraseña'),
            leading: const Icon(Icons.lock_outline),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Cerrar Sesión'),
            leading: const Icon(Icons.logout, color: Colors.red),
            textColor: Colors.red,
            iconColor: Colors.red,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
