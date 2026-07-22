import 'package:flutter/material.dart';
import 'package:vocra_flutter/vocra_flutter.dart';

/// Full-width strip that names the current turn state with a matching tint.
class StatusBanner extends StatelessWidget {
  const StatusBanner({super.key, required this.state});

  final TurnState state;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (state) {
      TurnState.idle => ('Idle', Colors.grey),
      TurnState.listening => ('Listening…', Colors.blue),
      TurnState.thinking => ('Thinking…', Colors.orange),
      TurnState.speaking => ('Speaking…', Colors.green),
    };

    return Container(
      width: double.infinity,
      color: color.withValues(alpha: 0.15),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
