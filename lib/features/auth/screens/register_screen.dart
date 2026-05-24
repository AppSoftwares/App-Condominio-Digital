// apps/mobile/lib/features/auth/screens/register_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                'Crea tu cuenta para gestionar tu condominio',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              // Aquí irían los campos de nombre, apellido, email, password, y selección de casa
              const TextField(
                decoration: InputDecoration(labelText: 'Nombre Completo'),
              ),
              const SizedBox(height: 16),
              const TextField(
                decoration: InputDecoration(labelText: 'Correo Electrónico'),
              ),
              const SizedBox(height: 32),

              FilledButton(
                onPressed: () {
                  // Lógica de registro
                },
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text('Registrarse'),
              ),

              const SizedBox(height: 20),
              const Text('O utiliza tu cuenta social'),
              const SizedBox(height: 16),

              OutlinedButton.icon(
                onPressed: () {
                  // Lógica de Google Sign In también aquí
                },
                icon: const Icon(Icons.account_circle),
                label: const Text('Registrarse con Google'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
