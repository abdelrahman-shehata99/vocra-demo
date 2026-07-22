import 'package:flutter/material.dart';

/// Red strip shown when the session surfaces an error.
class ErrorBanner extends StatelessWidget {
  const ErrorBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.red.shade100,
      padding: const EdgeInsets.all(8),
      child: Text(message, style: const TextStyle(color: Colors.red)),
    );
  }
}
