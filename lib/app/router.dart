import 'package:flutter/material.dart';

import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/handover/presentation/handover_screen.dart';
import '../features/incidents/presentation/incidents_screen.dart';
import '../features/vitals/presentation/vitals_screen.dart';

/// The app's primary navigation shell.
///
/// design.md §5 requires the four primary destinations (Dashboard, Vitals,
/// Incidents, Handover) to live in a persistent bottom navigation bar, and
/// explicitly says not to hide them inside a hamburger menu. An
/// [IndexedStack] is used so each tab keeps its own state when switching
/// away and back, rather than being rebuilt from scratch.
///
/// This is deliberately a plain [StatefulWidget], not a routing package —
/// there is no deep-link or nested-route requirement yet. If one emerges
/// in a later phase, this is the single place that would change.
class CareCircleShell extends StatefulWidget {
  const CareCircleShell({super.key});

  @override
  State<CareCircleShell> createState() => _CareCircleShellState();
}

class _CareCircleShellState extends State<CareCircleShell> {
  int _currentIndex = 0;

  static const List<Widget> _tabs = <Widget>[
    DashboardScreen(),
    VitalsScreen(),
    IncidentsScreen(),
    HandoverScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) => setState(() => _currentIndex = index),
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.monitor_heart_outlined),
            selectedIcon: Icon(Icons.monitor_heart),
            label: 'Vitals',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_note_outlined),
            selectedIcon: Icon(Icons.event_note),
            label: 'Incidents',
          ),
          NavigationDestination(
            icon: Icon(Icons.summarize_outlined),
            selectedIcon: Icon(Icons.summarize),
            label: 'Handover',
          ),
        ],
      ),
    );
  }
}
