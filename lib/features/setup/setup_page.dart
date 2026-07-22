import 'package:flutter/material.dart';
import 'package:vocra_flutter/vocra_flutter.dart';

import '../conversation/conversation_page.dart';
import 'setup_controller.dart';
import 'widgets/conversation_section.dart';
import 'widgets/llm_section.dart';
import 'widgets/persona_section.dart';
import 'widgets/policies_section.dart';
import 'widgets/stt_section.dart';
import 'widgets/tts_section.dart';

/// Step 1: pick providers/models/voices, enter keys, launch the conversation.
///
/// State lives in [SetupController]; this widget just owns its lifecycle and
/// rebuilds the form when the controller notifies.
class SetupPage extends StatefulWidget {
  const SetupPage({super.key});

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  final _controller = SetupController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _start() {
    final VocraSession session;
    try {
      session = _controller.buildSession();
    } on SetupValidationError catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ConversationPage(session: session)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vocra SDK Demo')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Every section reads reactive form state, so one builder around the
          // lot keeps them in sync while isolating rebuilds to this list.
          ListenableBuilder(
            listenable: _controller,
            builder: (context, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LlmSection(controller: _controller),
                TtsSection(controller: _controller),
                SttSection(controller: _controller),
                PersonaSection(controller: _controller),
                ConversationSection(controller: _controller),
                PoliciesSection(controller: _controller),
              ],
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _start,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('Start conversation'),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Deepgram always does the listening (STT); the toggles above pick '
            'who thinks (LLM) and who speaks (TTS).',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
