import 'dart:async';

import 'package:flutter/material.dart';
import 'package:voice_flutter/voice_flutter.dart';

void main() => runApp(const VocraDemoApp());

class VocraDemoApp extends StatelessWidget {
  const VocraDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vocra SDK Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const SetupPage(),
    );
  }
}

enum LlmChoice { groq, gemini }

enum TtsChoice { deepgram, elevenlabs }

const _groqModels = <String, String>{
  'llama-3.1-8b-instant': 'Llama 3.1 8B Instant ⚡',
  'llama-3.3-70b-versatile': 'Llama 3.3 70B Versatile',
  'openai/gpt-oss-20b': 'GPT-OSS 20B',
};

const _geminiModels = <String, String>{
  'gemini-2.5-flash': 'Gemini 2.5 Flash',
  'gemini-2.5-flash-lite': 'Gemini 2.5 Flash-Lite ⚡',
  'gemini-2.0-flash': 'Gemini 2.0 Flash',
};

const _deepgramVoices = <String, String>{
  'aura-asteria-en': 'Asteria — warm, natural (F)',
  'aura-luna-en': 'Luna — soft, gentle (F)',
  'aura-stella-en': 'Stella — clear, bright (F)',
  'aura-athena-en': 'Athena — British, poised (F)',
  'aura-hera-en': 'Hera — mature, confident (F)',
  'aura-orion-en': 'Orion — deep, resonant (M)',
  'aura-arcas-en': 'Arcas — smooth, calm (M)',
  'aura-perseus-en': 'Perseus — bold, clear (M)',
  'aura-angus-en': 'Angus — Irish, warm (M)',
  'aura-orpheus-en': 'Orpheus — rich, expressive (M)',
  'aura-helios-en': 'Helios — British, articulate (M)',
  'aura-zeus-en': 'Zeus — commanding, deep (M)',
};

const _elevenLabsVoices = <String, String>{
  'EXAVITQu4vr4xnSDxMaL': 'Sarah — soft, warm (F)',
  '21m00Tcm4TlvDq8ikWAM': 'Rachel — calm, clear (F)',
  'AZnzlk1XvdvUeBnXmlld': 'Domi — strong, confident (F)',
  'MF3mGyEYCl7XYWbV9V6O': 'Elli — youthful, friendly (F)',
  'ThT5KcBeYPX3keUQqHPh': 'Dorothy — deep, narration (F)',
  'pNInz6obpgDQGcFmaJgB': 'Adam — deep, versatile (M)',
  'yoZ06aMxZJJ28mfd3POQ': 'Sam — smooth, professional (M)',
  'TxGEqnHWrfWFTfGW9XjX': 'Josh — engaging, warm (M)',
  'VR6AewLTigWG4xSOukaG': 'Arnold — bold, commanding (M)',
  'ErXwobaYiN019PkySvjV': 'Antoni — friendly, casual (M)',
};

/// Step 1: pick providers/models/voices, enter keys, launch the conversation.
class SetupPage extends StatefulWidget {
  const SetupPage({super.key});

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  // TEMP debug pre-fill for emulator smoke test.
  final _groqKey = TextEditingController(
    text: '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',
  );
  final _geminiKey = TextEditingController();
  final _deepgramKey = TextEditingController(
    text: 'a4ee3a50f8f98de87b27571ae13c2a41867a0f6e',
  );
  final _elevenLabsKey = TextEditingController();
  final _persona = TextEditingController(
    text: 'You are a friendly, concise voice assistant.',
  );

  LlmChoice _llm = LlmChoice.groq;
  TtsChoice _tts = TtsChoice.deepgram;
  String _groqModel = _groqModels.keys.first;
  String _geminiModel = _geminiModels.keys.first;
  String _deepgramVoice = _deepgramVoices.keys.first;
  String _elevenLabsVoice = _elevenLabsVoices.keys.first;

  @override
  void dispose() {
    _groqKey.dispose();
    _geminiKey.dispose();
    _deepgramKey.dispose();
    _elevenLabsKey.dispose();
    _persona.dispose();
    super.dispose();
  }

  void _snack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _start() {
    final groqKey = _groqKey.text.trim();
    final geminiKey = _geminiKey.text.trim();
    final dgKey = _deepgramKey.text.trim();
    final elKey = _elevenLabsKey.text.trim();

    if (_llm == LlmChoice.groq && groqKey.isEmpty) {
      return _snack('Enter your Groq API key.');
    }
    if (_llm == LlmChoice.gemini && geminiKey.isEmpty) {
      return _snack('Enter your Gemini API key.');
    }
    // Deepgram is always needed: it does the speech recognition (STT).
    if (dgKey.isEmpty) {
      return _snack('Enter your Deepgram API key (used to hear you).');
    }
    if (_tts == TtsChoice.elevenlabs && elKey.isEmpty) {
      return _snack('Enter your ElevenLabs API key.');
    }

    // ── This is the entire SDK integration ────────────────────────────
    final session = VoiceSession(
      config: VoiceConfig(
        llm: _llm == LlmChoice.groq
            ? GroqLlm(apiKey: groqKey, model: _groqModel)
            : GeminiLlm(apiKey: geminiKey, model: _geminiModel),
        tts: _tts == TtsChoice.deepgram
            ? DeepgramTts(apiKey: dgKey, model: _deepgramVoice)
            : ElevenLabsTts(apiKey: elKey, voiceId: _elevenLabsVoice),
        stt: DeepgramStt(apiKey: dgKey),
        systemPrompt: _persona.text.trim().isEmpty
            ? 'You are a helpful assistant.'
            : _persona.text.trim(),
      ),
    );
    // ──────────────────────────────────────────────────────────────────

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ConversationPage(session: session)),
    );
  }

  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.only(top: 20, bottom: 8),
    child: Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.1,
        color: Theme.of(context).colorScheme.primary,
      ),
    ),
  );

  Widget _keyField(TextEditingController controller, String label) =>
      TextField(
        controller: controller,
        obscureText: true,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      );

  Widget _dropdown(
    String label,
    Map<String, String> options,
    String value,
    ValueChanged<String> onChanged,
  ) => DropdownButtonFormField<String>(
    initialValue: value,
    isExpanded: true,
    decoration: InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
      isDense: true,
    ),
    items: [
      for (final e in options.entries)
        DropdownMenuItem(
          value: e.key,
          child: Text(e.value, overflow: TextOverflow.ellipsis),
        ),
    ],
    onChanged: (v) => onChanged(v!),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vocra SDK Demo')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionLabel('AI model (LLM)'),
          SegmentedButton<LlmChoice>(
            segments: const [
              ButtonSegment(value: LlmChoice.groq, label: Text('Groq')),
              ButtonSegment(value: LlmChoice.gemini, label: Text('Gemini')),
            ],
            selected: {_llm},
            onSelectionChanged: (s) => setState(() => _llm = s.first),
          ),
          const SizedBox(height: 12),
          if (_llm == LlmChoice.groq) ...[
            _keyField(_groqKey, 'Groq API key (gsk_…)'),
            const SizedBox(height: 12),
            _dropdown(
              'Model',
              _groqModels,
              _groqModel,
              (v) => setState(() => _groqModel = v),
            ),
          ] else ...[
            _keyField(_geminiKey, 'Gemini API key (AIza…)'),
            const SizedBox(height: 12),
            _dropdown(
              'Model',
              _geminiModels,
              _geminiModel,
              (v) => setState(() => _geminiModel = v),
            ),
          ],
          _sectionLabel('Voice (TTS)'),
          SegmentedButton<TtsChoice>(
            segments: const [
              ButtonSegment(value: TtsChoice.deepgram, label: Text('Deepgram')),
              ButtonSegment(
                value: TtsChoice.elevenlabs,
                label: Text('ElevenLabs'),
              ),
            ],
            selected: {_tts},
            onSelectionChanged: (s) => setState(() => _tts = s.first),
          ),
          const SizedBox(height: 12),
          if (_tts == TtsChoice.deepgram)
            _dropdown(
              'Voice',
              _deepgramVoices,
              _deepgramVoice,
              (v) => setState(() => _deepgramVoice = v),
            )
          else ...[
            _keyField(_elevenLabsKey, 'ElevenLabs API key (sk_…)'),
            const SizedBox(height: 12),
            _dropdown(
              'Voice',
              _elevenLabsVoices,
              _elevenLabsVoice,
              (v) => setState(() => _elevenLabsVoice = v),
            ),
          ],
          _sectionLabel('Speech recognition (STT)'),
          _keyField(_deepgramKey, 'Deepgram API key (always required)'),
          _sectionLabel('Persona'),
          TextField(
            controller: _persona,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'System prompt',
              border: OutlineInputBorder(),
              isDense: true,
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

/// Step 2: drive the session and render its streams.
class ConversationPage extends StatefulWidget {
  const ConversationPage({super.key, required this.session});

  final VoiceSession session;

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  late final VoiceSession _session = widget.session;
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  TurnState _state = TurnState.idle;
  final List<TranscriptEvent> _transcript = [];
  TurnMetrics? _metrics;
  String? _error;
  bool _busy = false;

  final _subs = <StreamSubscription<dynamic>>[];

  bool get _live => _state != TurnState.idle;

  static String _ms(Duration? d) =>
      d == null ? '—' : '${d.inMilliseconds}ms';

  @override
  void initState() {
    super.initState();
    _subs.add(_session.turnState.listen((s) => setState(() => _state = s)));
    _subs.add(_session.metrics.listen((m) => setState(() => _metrics = m)));
    _subs.add(
      _session.errors.listen((e) => setState(() => _error = e.message)),
    );
    _subs.add(
      _session.transcripts.listen((event) {
        setState(() {
          final last = _transcript.isEmpty ? null : _transcript.last;
          // Any event from the same speaker REPLACES a preceding interim —
          // interim→interim gives live word-by-word updating, and the final
          // replaces the last interim in place instead of appending a
          // duplicate bubble.
          if (last != null && !last.isFinal && last.source == event.source) {
            _transcript[_transcript.length - 1] = event;
          } else {
            _transcript.add(event);
          }
        });
        _autoScroll();
      }),
    );
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
    for (final s in _subs) {
      s.cancel();
    }
    _textController.dispose();
    _scrollController.dispose();
    _session.dispose();
    super.dispose();
  }

  Future<void> _toggleMic() async {
    if (_live) {
      await _session.stop();
      return;
    }
    setState(() => _busy = true);
    try {
      await _session.requestPermissions();
      await _session.start();
    } catch (e) {
      if (mounted) setState(() => _error = 'start failed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _sendTyped() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _textController.clear();
    await _session.sendText(text);
  }

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (_state) {
      TurnState.idle => ('Idle', Colors.grey),
      TurnState.listening => ('Listening…', Colors.blue),
      TurnState.thinking => ('Thinking…', Colors.orange),
      TurnState.speaking => ('Speaking…', Colors.green),
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Conversation')),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: color.withValues(alpha: 0.15),
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
          ),
          if (_error != null)
            Container(
              width: double.infinity,
              color: Colors.red.shade100,
              padding: const EdgeInsets.all(8),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
          if (_metrics != null)
            Padding(
              padding: const EdgeInsets.all(6),
              child: Text(
                // Full pipeline breakdown, in causal order: LLM first token →
                // first sentence assembled → first TTS clip ready → first
                // audio audible → whole reply finished.
                'ttft ${_ms(_metrics!.ttft)} · '
                'sent ${_ms(_metrics!.firstSentenceReady)} · '
                'tts ${_ms(_metrics!.firstTtsReady)} · '
                'voice ${_ms(_metrics!.timeToFirstVoice)} · '
                'total ${_ms(_metrics!.total)}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          Expanded(
            child: _transcript.isEmpty
                ? const Center(child: Text('Tap the mic or type below.'))
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(12),
                    itemCount: _transcript.length,
                    itemBuilder: (context, i) {
                      final e = _transcript[i];
                      final isUser = e.source == TranscriptSource.user;
                      return Align(
                        alignment: isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.78,
                          ),
                          decoration: BoxDecoration(
                            color: isUser
                                ? Theme.of(context).colorScheme.primaryContainer
                                : Theme.of(
                                    context,
                                  ).colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            e.text.isEmpty ? '…' : e.text,
                            style: e.isFinal
                                ? null
                                : TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.75),
                                  ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendTyped(),
                      decoration: const InputDecoration(
                        hintText: 'Type a message…',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _sendTyped,
                  ),
                  IconButton(
                    onPressed: _busy ? null : _toggleMic,
                    icon: _busy
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(_live ? Icons.stop : Icons.mic),
                    color: _live
                        ? Colors.red
                        : Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
