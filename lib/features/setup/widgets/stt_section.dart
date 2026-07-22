import 'package:flutter/material.dart';

import '../setup_controller.dart';
import 'secret_field.dart';
import 'section_label.dart';

/// "Speech recognition (STT)" block. Deepgram always does the listening, so its
/// key is always required.
class SttSection extends StatelessWidget {
  const SttSection({super.key, required this.controller});

  final SetupController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel('Speech recognition (STT)'),
        SecretField(
          controller: controller.deepgramKey,
          label: 'Deepgram API key (always required)',
        ),
      ],
    );
  }
}
