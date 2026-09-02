import 'package:flutter/material.dart';

/// Reusable error state (design.md §14 / §18 — "ErrorStateCard").
///
/// Always shows a human-readable [message] — never a raw exception or
/// stack trace (design.md's example: not `HiveError: Box not found`, but
/// "We couldn't load your care records. Please try again.").
class ErrorStateCard extends StatelessWidget {
  const ErrorStateCard({
    super.key,
    this.message = "We couldn't load your care records.\n\nPlease try again.",
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
