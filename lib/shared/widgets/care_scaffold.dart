import 'package:flutter/material.dart';

/// Base scaffold used by every top-level screen.
///
/// This is the first entry in design.md §18's component library. Keeping
/// it as a thin wrapper now (rather than a fully-featured component) means
/// every screen already shares one place to later add cross-cutting
/// behavior — e.g. a consistent app-bar treatment or reduced-motion
/// handling — without editing every screen individually.
class CareScaffold extends StatelessWidget {
  const CareScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
  });

  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: Theme.of(context).textTheme.headlineMedium),
        actions: actions,
      ),
      body: SafeArea(child: body),
      floatingActionButton: floatingActionButton,
    );
  }
}
