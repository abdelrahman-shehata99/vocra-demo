import 'package:flutter/material.dart';

/// Bottom input row: a text field, a send button, and the mic/stop button.
///
/// Owns its own [TextEditingController] and clears it after a send, so the
/// parent never has to manage typed-message state.
class Composer extends StatefulWidget {
  const Composer({
    super.key,
    required this.busy,
    required this.isLive,
    required this.onSend,
    required this.onToggleMic,
  });

  final bool busy;
  final bool isLive;
  final ValueChanged<String> onSend;
  final VoidCallback onToggleMic;

  @override
  State<Composer> createState() => _ComposerState();
}

class _ComposerState extends State<Composer> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    widget.onSend(text);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
                decoration: const InputDecoration(
                  hintText: 'Type a message…',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
            IconButton(icon: const Icon(Icons.send), onPressed: _send),
            IconButton(
              onPressed: widget.busy ? null : widget.onToggleMic,
              icon: widget.busy
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(widget.isLive ? Icons.stop : Icons.mic),
              color: widget.isLive
                  ? Colors.red
                  : Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}
