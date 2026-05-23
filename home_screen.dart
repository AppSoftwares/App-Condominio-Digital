// apps/mobile/lib/core/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.child});
  final Widget child;

  static const _tabs = [
    (icon: Icons.account_balance_wallet_outlined, label: 'Finanzas', path: '/home'),
    (icon: Icons.event_available_outlined,        label: 'Reservas', path: '/reservas'),
    (icon: Icons.receipt_long_outlined,           label: 'Cuotas',   path: '/cobranza'),
    (icon: Icons.chat_bubble_outline,             label: 'Chat',     path: '/chat'),
    (icon: Icons.how_to_vote_outlined,            label: 'Votar',    path: '/votaciones'),
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final idx = _tabs.indexWhere((t) => location.startsWith(t.path));
    return idx < 0 ? 0 : idx;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex(context),
        onDestinationSelected: (i) => context.go(_tabs[i].path),
        destinations: _tabs.map((t) => NavigationDestination(
          icon: Icon(t.icon),
          label: t.label,
        )).toList(),
      ),
    );
  }
}
