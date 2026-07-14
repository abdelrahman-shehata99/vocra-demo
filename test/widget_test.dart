import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vocra_demo/main.dart';

void main() {
  testWidgets('setup screen renders provider pickers and validates keys', (
    tester,
  ) async {
    await tester.pumpWidget(const VocraDemoApp());
    await tester.pump();

    // LLM + TTS provider toggles.
    expect(find.text('Groq'), findsOneWidget);
    expect(find.text('Gemini'), findsOneWidget);
    expect(find.text('Deepgram'), findsOneWidget);
    expect(find.text('ElevenLabs'), findsOneWidget);

    // Default panels: Groq key + model dropdown, Deepgram voice dropdown.
    expect(find.text('Groq API key (gsk_…)'), findsOneWidget);
    expect(find.text('Model'), findsOneWidget);
    expect(find.text('Voice'), findsOneWidget);
    expect(find.text('Deepgram API key (always required)'), findsOneWidget);

    // Switching the LLM toggle swaps the key/model panel.
    await tester.tap(find.text('Gemini'));
    await tester.pumpAndSettle();
    expect(find.text('Gemini API key (AIza…)'), findsOneWidget);
    expect(find.text('Groq API key (gsk_…)'), findsNothing);

    // Switching TTS to ElevenLabs asks for its key.
    await tester.tap(find.text('ElevenLabs'));
    await tester.pumpAndSettle();
    expect(find.text('ElevenLabs API key (sk_…)'), findsOneWidget);

    // Starting without the selected LLM's key shows a validation message.
    await tester.dragUntilVisible(
      find.widgetWithText(FilledButton, 'Start conversation'),
      find.byType(ListView),
      const Offset(0, -200),
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Start conversation'));
    await tester.pump();
    expect(find.text('Enter your Gemini API key.'), findsOneWidget);
  });
}
