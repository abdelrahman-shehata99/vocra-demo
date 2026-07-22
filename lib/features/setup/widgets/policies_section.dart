import 'package:flutter/material.dart';

import '../setup_controller.dart';
import 'section_label.dart';

/// "Auto-end policies" block: end phrases, farewell message, and the silence /
/// max-duration caps. All optional — blank fields disable the rule.
class PoliciesSection extends StatelessWidget {
  const PoliciesSection({super.key, required this.controller});

  final SetupController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel('Auto-end policies (optional)'),
        TextField(
          controller: controller.endPhrases,
          decoration: const InputDecoration(
            labelText: 'End phrases (comma-separated)',
            border: OutlineInputBorder(),
            isDense: true,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller.endMessage,
          decoration: const InputDecoration(
            labelText: 'Farewell spoken before an auto-end',
            border: OutlineInputBorder(),
            isDense: true,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller.silenceSeconds,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Silence timeout (s)',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: controller.maxMinutes,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Max duration (min)',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
