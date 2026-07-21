import 'dart:async';

import 'package:flutter/material.dart';
import 'package:vocra/vocra.dart';

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

enum LlmChoice { groq, openai, gemini }

enum TtsChoice { deepgram, elevenlabs }

const _groqModels = <String, String>{
  'openai/gpt-oss-20b': 'GPT-OSS 20B ⚡ (default)',
  'llama-3.3-70b-versatile': 'Llama 3.3 70B Versatile',
  'llama-3.1-8b-instant': 'Llama 3.1 8B Instant (retires 2026-08-16)',
};

const _openAiModels = <String, String>{
  'gpt-4.1-mini': 'GPT-4.1 Mini ⚡ (default)',
  'gpt-4.1-nano': 'GPT-4.1 Nano (fastest)',
  'gpt-4.1': 'GPT-4.1',
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

const _elevenLabsModels = <String, String>{
  'eleven_flash_v2_5': 'Flash v2.5 — fastest (default)',
  'eleven_turbo_v2_5': 'Turbo v2.5 — fast, higher quality',
  'eleven_multilingual_v2': 'Multilingual v2',
  'eleven_v3': 'Eleven v3 — most expressive, [laughs] tags',
};

/// Step 1: pick providers/models/voices, enter keys, launch the conversation.
class SetupPage extends StatefulWidget {
  const SetupPage({super.key});

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  // Keys are read from --dart-define at build time so nothing sensitive is
  // committed. Run e.g.:
  //   flutter run --dart-define=GROQ_API_KEY=... --dart-define=DEEPGRAM_API_KEY=...
  final _groqKey = TextEditingController(
    text: const String.fromEnvironment('GROQ_API_KEY'),
  );
  final _openAiKey = TextEditingController(
    text: const String.fromEnvironment('OPENAI_API_KEY'),
  );
  final _geminiKey = TextEditingController(
    text: const String.fromEnvironment('GEMINI_API_KEY'),
  );
  final _deepgramKey = TextEditingController(
    text: const String.fromEnvironment('DEEPGRAM_API_KEY'),
  );
  final _elevenLabsKey = TextEditingController(
    text: const String.fromEnvironment('ELEVENLABS_API_KEY'),
  );
  final _persona = TextEditingController(
    text: 'You are a friendly, concise voice assistant.',
  );
  final _assistantName = TextEditingController();
  final _greeting = TextEditingController(
    text: 'Hey there! What can I help you with today?',
  );
  // Session policies (leave blank to disable).
  final _endPhrases = TextEditingController(text: 'goodbye, talk to you later');
  final _endMessage = TextEditingController(
    text: 'Thanks for chatting. Take care!',
  );
  final _silenceSeconds = TextEditingController();
  final _maxMinutes = TextEditingController();

  LlmChoice _llm = LlmChoice.groq;
  TtsChoice _tts = TtsChoice.deepgram;
  String _groqModel = _groqModels.keys.first;
  String _openAiModel = _openAiModels.keys.first;
  String _geminiModel = _geminiModels.keys.first;
  String _deepgramVoice = _deepgramVoices.keys.first;
  String _elevenLabsVoice = _elevenLabsVoices.keys.first;
  String _elevenLabsModel = _elevenLabsModels.keys.first;
  bool _naturalSpeech = true;

  @override
  void dispose() {
    _groqKey.dispose();
    _openAiKey.dispose();
    _geminiKey.dispose();
    _deepgramKey.dispose();
    _elevenLabsKey.dispose();
    _persona.dispose();
    _assistantName.dispose();
    _greeting.dispose();
    _endPhrases.dispose();
    _endMessage.dispose();
    _silenceSeconds.dispose();
    _maxMinutes.dispose();
    super.dispose();
  }

  void _snack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _start() {
    final groqKey = _groqKey.text.trim();
    final openAiKey = _openAiKey.text.trim();
    final geminiKey = _geminiKey.text.trim();
    final dgKey = _deepgramKey.text.trim();
    final elKey = _elevenLabsKey.text.trim();

    if (_llm == LlmChoice.groq && groqKey.isEmpty) {
      return _snack('Enter your Groq API key.');
    }
    if (_llm == LlmChoice.openai && openAiKey.isEmpty) {
      return _snack('Enter your OpenAI API key.');
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

    final greetingText = _greeting.text.trim();
    final assistantName = _assistantName.text.trim();

    // ── This is the entire SDK integration ────────────────────────────
    final session = VocraSession(
      config: VocraConfig(
        // Provider facades pick the service in one line.
        llm: switch (_llm) {
          LlmChoice.groq => VocraLlm.groq(apiKey: groqKey, model: _groqModel),
          LlmChoice.openai => VocraLlm.openAi(
            apiKey: openAiKey,
            model: _openAiModel,
          ),
          LlmChoice.gemini => VocraLlm.gemini(
            apiKey: geminiKey,
            model: _geminiModel,
          ),
        },
        tts: _tts == TtsChoice.deepgram
            ? VocraTts.deepgram(apiKey: dgKey, voice: _deepgramVoice)
            : VocraTts.elevenLabs(
                apiKey: elKey,
                voiceId: _elevenLabsVoice,
                model: _elevenLabsModel,
              ),
        stt: VocraStt.deepgram(apiKey: dgKey),
        systemPrompt: _persona.text.trim().isEmpty
            ? 'You are a helpful assistant.'
            : _persona.text.trim(),
        assistantName: assistantName.isEmpty ? null : assistantName,
        // The AI speaks first with this line (empty = user speaks first).
        greeting: greetingText.isEmpty ? null : Greeting.text(greetingText),
        // Nudge the model toward brief, spoken-style replies; strips markdown/
        // emojis before TTS and enables [laughs]-style tags on ElevenLabs v3.
        naturalSpeech: _naturalSpeech,
        // Auto-end rules — say an end phrase, go silent, or hit the cap.
        policies: _buildPolicies(),
      ),
    );
    // ──────────────────────────────────────────────────────────────────

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ConversationPage(session: session)),
    );
  }

  SessionPolicies _buildPolicies() {
    final phrases = _endPhrases.text
        .split(',')
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();
    final silence = int.tryParse(_silenceSeconds.text.trim());
    final maxMin = int.tryParse(_maxMinutes.text.trim());
    final endMsg = _endMessage.text.trim();
    return SessionPolicies(
      endPhrases: phrases,
      endMessage: endMsg.isEmpty ? null : endMsg,
      silenceTimeout: silence == null ? null : Duration(seconds: silence),
      maxDuration: maxMin == null ? null : Duration(minutes: maxMin),
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

  Widget _keyField(TextEditingController controller, String label) => TextField(
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
              ButtonSegment(value: LlmChoice.openai, label: Text('OpenAI')),
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
          ] else if (_llm == LlmChoice.openai) ...[
            _keyField(_openAiKey, 'OpenAI API key (sk-…)'),
            const SizedBox(height: 12),
            _dropdown(
              'Model',
              _openAiModels,
              _openAiModel,
              (v) => setState(() => _openAiModel = v),
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
            const SizedBox(height: 12),
            _dropdown(
              'Model',
              _elevenLabsModels,
              _elevenLabsModel,
              (v) => setState(() => _elevenLabsModel = v),
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
          const SizedBox(height: 12),
          TextField(
            controller: _assistantName,
            decoration: const InputDecoration(
              labelText: 'Assistant name (optional, e.g. Riley)',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          _sectionLabel('Conversation'),
          TextField(
            controller: _greeting,
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
            value: _naturalSpeech,
            onChanged: (v) => setState(() => _naturalSpeech = v),
          ),
          _sectionLabel('Auto-end policies (optional)'),
          TextField(
            controller: _endPhrases,
            decoration: const InputDecoration(
              labelText: 'End phrases (comma-separated)',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _endMessage,
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
                  controller: _silenceSeconds,
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
                  controller: _maxMinutes,
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

  final VocraSession session;

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  late final VocraSession _session = widget.session;
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  TurnState _state = TurnState.idle;
  List<TranscriptEvent> _transcript = const [];
  TurnMetrics? _metrics;
  String? _error;
  bool _busy = false;
  bool _muted = false;

  VocraSubscription? _sub;

  bool get _live => _state != TurnState.idle;

  static String _ms(Duration? d) => d == null ? '—' : '${d.inMilliseconds}ms';

  @override
  void initState() {
    super.initState();
    // One observe() call, and the SDK hands us the already-merged conversation.
    _sub = _session.observe(
      onState: (s) => setState(() => _state = s),
      onMetrics: (m) => setState(() => _metrics = m),
      onError: (e) => setState(() => _error = e.message),
      onMessages: (messages) {
        setState(() => _transcript = messages);
        _autoScroll();
      },
    );
    // The session can end itself (an end phrase, silence, or max duration) —
    // surface the report when that happens.
    _session.sessionEnded.first.then((report) {
      if (mounted) _showReport(report);
    });
  }

  Future<void> _toggleMute() async {
    setState(() {
      _muted = !_muted;
      _muted ? _session.mute() : _session.unmute();
    });
  }

  Future<void> _endSession() async {
    if (!_live) return;
    try {
      final report = await _session.endSession();
      if (mounted) _showReport(report);
    } catch (e) {
      if (mounted) setState(() => _error = 'endSession failed: $e');
    }
  }

  void _showReport(SessionReport report) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Session report'),
        content: Text(
          'Reason: ${report.endReason.name}\n'
          'Messages: ${report.messages.length}\n'
          'Turns: ${report.turnCount}\n'
          'Duration: ${report.duration.inSeconds}s',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
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
    _sub?.cancel();
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
      appBar: AppBar(
        title: const Text('Conversation'),
        actions: [
          IconButton(
            tooltip: _muted ? 'Unmute' : 'Mute',
            icon: Icon(_muted ? Icons.mic_off : Icons.mic),
            onPressed: _live ? _toggleMute : null,
          ),
          IconButton(
            tooltip: 'End session',
            icon: const Icon(Icons.call_end),
            onPressed: _live ? _endSession : null,
          ),
        ],
      ),
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
