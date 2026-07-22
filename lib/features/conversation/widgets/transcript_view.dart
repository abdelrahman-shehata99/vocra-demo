import 'package:flutter/material.dart';
import 'package:vocra_flutter/vocra_flutter.dart';

import 'message_bubble.dart';

/// Scrollable list of conversation bubbles that auto-scrolls to the newest
/// message. Shows a hint when the transcript is empty.
class TranscriptView extends StatefulWidget {
  const TranscriptView({super.key, required this.transcript});

  final List<TranscriptEvent> transcript;

  @override
  State<TranscriptView> createState() => _TranscriptViewState();
}

class _TranscriptViewState extends State<TranscriptView> {
  final _scrollController = ScrollController();

  @override
  void didUpdateWidget(TranscriptView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.transcript.length != oldWidget.transcript.length) {
      _autoScroll();
    }
  }

  void _autoScroll() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.transcript.isEmpty) {
      return const Center(child: Text('Tap the mic or type below.'));
    }
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(12),
      itemCount: widget.transcript.length,
      itemBuilder: (context, i) => MessageBubble(event: widget.transcript[i]),
    );
  }
}
