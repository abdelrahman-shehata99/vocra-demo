import 'package:flutter/material.dart';
import 'package:vocra_flutter/vocra_flutter.dart';

import '../../../shared/format.dart';

/// One-line latency breakdown for the last turn, in causal order:
/// LLM first token → first sentence assembled → first TTS clip ready →
/// first audio audible → whole reply finished.
class MetricsBar extends StatelessWidget {
  const MetricsBar({super.key, required this.metrics});

  final TurnMetrics metrics;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Text(
        'ttft ${Format.ms(metrics.ttft)} · '
        'sent ${Format.ms(metrics.firstSentenceReady)} · '
        'tts ${Format.ms(metrics.firstTtsReady)} · '
        'voice ${Format.ms(metrics.timeToFirstVoice)} · '
        'total ${Format.ms(metrics.total)}',
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
    );
  }
}