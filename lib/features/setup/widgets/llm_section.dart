import 'package:flutter/material.dart';
import 'package:vocra_flutter/vocra_flutter.dart';

import '../setup_controller.dart';
import 'catalog_dropdown.dart';
import 'secret_field.dart';
import 'section_label.dart';

/// "AI model (LLM)" block: vendor picker plus the key + model panel for
/// whichever vendor is selected. Built straight from the SDK's typed enums.
class LlmSection extends StatelessWidget {
  const LlmSection({super.key, required this.controller});

  final SetupController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel('AI model (LLM)'),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SegmentedButton<LlmVendor>(
            segments: [
              for (final v in LlmVendor.values)
                ButtonSegment(value: v, label: Text(v.displayName)),
            ],
            selected: {controller.llm},
            onSelectionChanged: (s) => controller.llm = s.first,
          ),
        ),
        const SizedBox(height: 12),
        ..._vendorPanel(),
      ],
    );
  }

  List<Widget> _vendorPanel() => switch (controller.llm) {
    LlmVendor.groq => [
      SecretField(controller: controller.groqKey, label: 'Groq API key (gsk_…)'),
      const SizedBox(height: 12),
      CatalogDropdown(
        label: 'Model',
        options: GroqModel.values,
        value: controller.groqModel,
        onChanged: (v) => controller.groqModel = v,
      ),
    ],
    LlmVendor.openAi => [
      SecretField(controller: controller.openAiKey, label: 'OpenAI API key (sk-…)'),
      const SizedBox(height: 12),
      CatalogDropdown(
        label: 'Model',
        options: OpenAiModel.values,
        value: controller.openAiModel,
        onChanged: (v) => controller.openAiModel = v,
      ),
    ],
    LlmVendor.gemini => [
      SecretField(controller: controller.geminiKey, label: 'Gemini API key (AIza…)'),
      const SizedBox(height: 12),
      CatalogDropdown(
        label: 'Model',
        options: GeminiModel.values,
        value: controller.geminiModel,
        onChanged: (v) => controller.geminiModel = v,
      ),
    ],
    LlmVendor.xai => [
      SecretField(controller: controller.xaiKey, label: 'xAI API key (xai-…)'),
      const SizedBox(height: 12),
      CatalogDropdown(
        label: 'Model',
        options: XaiModel.values,
        value: controller.xaiModel,
        onChanged: (v) => controller.xaiModel = v,
      ),
    ],
    LlmVendor.zai => [
      SecretField(controller: controller.zaiKey, label: 'Z.ai API key'),
      const SizedBox(height: 12),
      CatalogDropdown(
        label: 'Model',
        options: ZaiModel.values,
        value: controller.zaiModel,
        onChanged: (v) => controller.zaiModel = v,
      ),
    ],
  };
}
