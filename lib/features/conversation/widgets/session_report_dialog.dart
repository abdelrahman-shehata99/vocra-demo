import 'package:flutter/material.dart';
import 'package:vocra_flutter/vocra_flutter.dart';

/// Summary shown when a session ends — manually or on its own (end phrase,
/// silence, or max duration).
class SessionReportDialog extends StatelessWidget {
  const SessionReportDialog({super.key, required this.report});

  final SessionReport report;

  /// Convenience for `showDialog(builder: ...)`.
  static Future<void> show(BuildContext context, SessionReport report) {
    return showDialog<void>(
      context: context,
      builder: (_) => SessionReportDialog(report: report),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Session report'),
      content: Text(
        'Reason: ${report.endReason.name}\n'
        'Messages: ${report.messages.length}\n'
        'Turns: ${report.turnCount}\n'
        'Duration: ${report.duration.inSeconds}s',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
