import 'package:flutter/material.dart';

import '../setup_controller.dart';
import 'section_label.dart';

/// "Conversation" block: the opening greeting and the natural-speech toggle.
class ConversationSection extends StatelessWidget {
  const ConversationSection({super.key, required this.controller});

  final SetupController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel('Conversation'),
        TextField(
          controller: controller.greeting,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText:
                'Greeting — the AI speaks this first (blank = user starts)',
            border: OutlineInputBorder(),
            isDense: true,
          ),
        ),
        const SizedBox(height: 4),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Natural speech'),
          subtitle: const Text(
            'Brief spoken-style replies; strips markdown/emojis, and enables '
            '[laughs]-style tags on ElevenLabs v3.',
            style: TextStyle(fontSize: 12),
          ),
          value: controller.naturalSpeech,
          onChanged: (v) => controller.naturalSpeech = v,
        ),
      ],
    );
  }
}
