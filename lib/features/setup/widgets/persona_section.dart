import 'package:flutter/material.dart';

import '../setup_controller.dart';
import 'section_label.dart';

/// "Persona" block: the system prompt and an optional assistant name.
class PersonaSection extends StatelessWidget {
  const PersonaSection({super.key, required this.controller});

  final SetupController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel('Persona'),
        TextField(
          controller: controller.persona,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'System prompt',
            border: OutlineInputBorder(),
            isDense: true,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller.assistantName,
          decoration: const InputDecoration(
            labelText: 'Assistant name (optional, e.g. Riley)',
            border: OutlineInputBorder(),
            isDense: true,
          ),
        ),
      ],
    );
  }
}
