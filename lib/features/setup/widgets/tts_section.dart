import 'package:flutter/material.dart';
import 'package:vocra_flutter/vocra_flutter.dart';

import '../setup_controller.dart';
import 'catalog_dropdown.dart';
import 'secret_field.dart';
import 'section_label.dart';

/// "Voice (TTS)" block: vendor toggle plus the voice/model panel for the
/// selected TTS provider.
class TtsSection extends StatelessWidget {
  const TtsSection({super.key, required this.controller});

  final SetupController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel('Voice (TTS)'),
        SegmentedButton<TtsVendor>(
          segments: [
            for (final v in TtsVendor.values)
              ButtonSegment(value: v, label: Text(v.displayName)),
          ],
          selected: {controller.tts},
          onSelectionChanged: (s) => controller.tts = s.first,
        ),
        const SizedBox(height: 12),
        ..._vendorPanel(),
      ],
    );
  }

  List<Widget> _vendorPanel() {
    if (controller.tts == TtsVendor.deepgram) {
      return [
        CatalogDropdown(
          label: 'Voice',
          options: DeepgramVoice.values,
          value: controller.deepgramVoice,
          onChanged: (v) => controller.deepgramVoice = v,
        ),
      ];
    }
    return [
      SecretField(
        controller: controller.elevenLabsKey,
        label: 'ElevenLabs API key (sk_…)',
      ),
      const SizedBox(height: 12),
      CatalogDropdown(
        label: 'Voice',
        options: ElevenLabsVoice.values,
        value: controller.elevenLabsVoice,
        onChanged: (v) => controller.elevenLabsVoice = v,
      ),
      const SizedBox(height: 12),
      CatalogDropdown(
        label: 'Model',
        options: ElevenLabsModel.values,
        value: controller.elevenLabsModel,
        onChanged: (v) => controller.elevenLabsModel = v,
      ),
    ];
  }
}
