import 'package:flutter/material.dart';
import 'package:vocra_flutter/vocra_flutter.dart';

/// A single chat bubble — right-aligned for the user, left for the assistant.
/// Interim (non-final) transcripts render dimmed.
class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.event});

  final TranscriptEvent event;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isUser = event.source == TranscriptSource.user;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        decoration: BoxDecoration(
          color: isUser
              ? scheme.primaryContainer
              : scheme.secondaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          event.text.isEmpty ? '…' : event.text,
          style: event.isFinal
              ? null
              : TextStyle(color: scheme.onSurface.withValues(alpha: 0.75)),
        ),
      ),
    );
  }
}
