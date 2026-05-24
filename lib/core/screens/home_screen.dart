// apps/mobile/lib/core/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.child});
  final Widget child;

  static const _bottomTabs = [
    (icon: Icons.home_outlined,             label: 'Inicio',   path: '/home'),
    (icon: Icons.security_outlined,         label: 'Visitas',  path: '/visitas'),
    (icon: Icons.notifications_none_outlined, label: 'Avisos',   path: '/bitacora'),
    (icon: Icons.account_balance_wallet_outlined, label: 'Finanzas', path: '/finanzas'),
    (icon: Icons.receipt_long_outlined,     label: 'Cuotas',   path: '/cobranza'),
  ];

  static const _drawerItems = [
    (icon: Icons.people_outline,           label: 'Comunidad',       path: '/comunidad'),
    (icon: Icons.inventory_2_outlined,     label: 'Correspondencia', path: '/correspondencia'),
    (icon: Icons.build_circle_outlined,    label: 'Mantenimiento',   path: '/mantenimiento'),
    (icon: Icons.event_available_outlined, label: 'Reservas',        path: '/reservas'),
    (icon: Icons.how_to_vote_outlined,     label: 'Votaciones',      path: '/votaciones'),
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final idx = _bottomTabs.indexWhere((t) => location.startsWith(t.path));
    return idx < 0 ? 0 : idx;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Caminos de la Lagunita'),
        actions: [
          IconButton(icon: const Icon(Icons.person_outline), onPressed: () => context.push('/perfil')),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            const UserAccountsDrawerHeader(
              accountName: Text('Residente Casa 14-71'),
              accountEmail: Text('propietario@condominio.com'),
              currentAccountPicture: CircleAvatar(child: Icon(Icons.person, size: 40)),
              decoration: BoxDecoration(color: Color(0xFFB5541A)),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: _drawerItems.map((item) => ListTile(
                  leading: Icon(item.icon),
                  title: Text(item.label),
                  onTap: () {
                    Navigator.pop(context);
                    context.go(item.path);
                  },
                )).toList(),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
              onTap: () {},
            ),
          ],
        ),
      ),
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex(context),
        onDestinationSelected: (i) => context.go(_bottomTabs[i].path),
        destinations: _bottomTabs.map((t) => NavigationDestination(
          icon: Icon(t.icon),
          label: t.label,
        )).toList(),
      ),
    );
  }
}
