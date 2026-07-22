import 'package:flutter/widgets.dart';
import 'package:vocra_flutter/vocra_flutter.dart';

/// Thrown by [SetupController.buildSession] when the form is missing a key the
/// chosen providers need. The [message] is user-facing.
class SetupValidationError implements Exception {
  const SetupValidationError(this.message);
  final String message;
}

/// Owns every piece of setup-form state — text controllers and the selected
/// provider/model/voice enums — and knows how to turn it into a [VocraSession].
///
/// Keeping this out of the widget means the screen only rebuilds the sections
/// that actually change, and the session-building logic is unit-testable
/// without pumping any UI.
class SetupController extends ChangeNotifier {
  // Keys default from --dart-define at build time so nothing sensitive is
  // committed. e.g. `flutter run --dart-define=GROQ_API_KEY=...`.
  final groqKey = _envField('GROQ_API_KEY');
  final openAiKey = _envField('OPENAI_API_KEY');
  final geminiKey = _envField('GEMINI_API_KEY');
  final deepgramKey = _envField('DEEPGRAM_API_KEY');
  final elevenLabsKey = _envField('ELEVENLABS_API_KEY');
  final xaiKey = _envField('XAI_API_KEY');
  final zaiKey = _envField('ZAI_API_KEY');

  final persona = TextEditingController(
    text: 'You are a friendly, concise voice assistant.',
  );
  final assistantName = TextEditingController();
  final greeting = TextEditingController(
    text: 'Hey there! What can I help you with today?',
  );

  // Session policies (leave blank to disable).
  final endPhrases = TextEditingController(text: 'goodbye, talk to you later');
  final endMessage = TextEditingController(
    text: 'Thanks for chatting. Take care!',
  );
  final silenceSeconds = TextEditingController();
  final maxMinutes = TextEditingController();

  LlmVendor _llm = LlmVendor.groq;
  TtsVendor _tts = TtsVendor.deepgram;
  GroqModel _groqModel = GroqModel.gptOss20b;
  OpenAiModel _openAiModel = OpenAiModel.gpt41Mini;
  GeminiModel _geminiModel = GeminiModel.flash25;
  XaiModel _xaiModel = XaiModel.grok43;
  ZaiModel _zaiModel = ZaiModel.glm46;
  DeepgramVoice _deepgramVoice = DeepgramVoice.asteria;
  ElevenLabsVoice _elevenLabsVoice = ElevenLabsVoice.sarah;
  ElevenLabsModel _elevenLabsModel = ElevenLabsModel.flashV25;
  bool _naturalSpeech = true;

  LlmVendor get llm => _llm;
  TtsVendor get tts => _tts;
  GroqModel get groqModel => _groqModel;
  OpenAiModel get openAiModel => _openAiModel;
  GeminiModel get geminiModel => _geminiModel;
  XaiModel get xaiModel => _xaiModel;
  ZaiModel get zaiModel => _zaiModel;
  DeepgramVoice get deepgramVoice => _deepgramVoice;
  ElevenLabsVoice get elevenLabsVoice => _elevenLabsVoice;
  ElevenLabsModel get elevenLabsModel => _elevenLabsModel;
  bool get naturalSpeech => _naturalSpeech;

  set llm(LlmVendor v) => _set(() => _llm = v);
  set tts(TtsVendor v) => _set(() => _tts = v);
  set groqModel(GroqModel v) => _set(() => _groqModel = v);
  set openAiModel(OpenAiModel v) => _set(() => _openAiModel = v);
  set geminiModel(GeminiModel v) => _set(() => _geminiModel = v);
  set xaiModel(XaiModel v) => _set(() => _xaiModel = v);
  set zaiModel(ZaiModel v) => _set(() => _zaiModel = v);
  set deepgramVoice(DeepgramVoice v) => _set(() => _deepgramVoice = v);
  set elevenLabsVoice(ElevenLabsVoice v) => _set(() => _elevenLabsVoice = v);
  set elevenLabsModel(ElevenLabsModel v) => _set(() => _elevenLabsModel = v);
  set naturalSpeech(bool v) => _set(() => _naturalSpeech = v);

  /// The API key entered for the currently selected LLM vendor.
  String get _activeLlmKey => switch (_llm) {
    LlmVendor.groq => groqKey.text.trim(),
    LlmVendor.openAi => openAiKey.text.trim(),
    LlmVendor.gemini => geminiKey.text.trim(),
    LlmVendor.xai => xaiKey.text.trim(),
    LlmVendor.zai => zaiKey.text.trim(),
  };

  /// Validates the form and builds the session — the entire SDK integration.
  ///
  /// Throws [SetupValidationError] with a user-facing message when a required
  /// key is missing.
  VocraSession buildSession() {
    final llmKey = _activeLlmKey;
    final dgKey = deepgramKey.text.trim();
    final elKey = elevenLabsKey.text.trim();

    if (llmKey.isEmpty) {
      throw SetupValidationError('Enter your ${_llm.displayName} API key.');
    }
    // Deepgram is always needed: it does the speech recognition (STT).
    if (dgKey.isEmpty) {
      throw const SetupValidationError(
        'Enter your Deepgram API key (used to hear you).',
      );
    }
    if (_tts == TtsVendor.elevenLabs && elKey.isEmpty) {
      throw const SetupValidationError('Enter your ElevenLabs API key.');
    }

    final persona = this.persona.text.trim();
    final assistantName = this.assistantName.text.trim();
    final greeting = this.greeting.text.trim();

    return VocraSession(
      config: VocraConfig(
        // Provider facades pick the service in one line, with typed models.
        llm: switch (_llm) {
          LlmVendor.groq => VocraLlm.groq(apiKey: llmKey, model: _groqModel),
          LlmVendor.openAi => VocraLlm.openAi(
            apiKey: llmKey,
            model: _openAiModel,
          ),
          LlmVendor.gemini => VocraLlm.gemini(
            apiKey: llmKey,
            model: _geminiModel,
          ),
          LlmVendor.xai => VocraLlm.xai(apiKey: llmKey, model: _xaiModel),
          LlmVendor.zai => VocraLlm.zai(apiKey: llmKey, model: _zaiModel),
        },
        tts: _tts == TtsVendor.deepgram
            ? VocraTts.deepgram(apiKey: dgKey, voice: _deepgramVoice)
            : VocraTts.elevenLabs(
                apiKey: elKey,
                voice: _elevenLabsVoice,
                model: _elevenLabsModel,
              ),
        stt: VocraStt.deepgram(apiKey: dgKey),
        systemPrompt: persona.isEmpty ? 'You are a helpful assistant.' : persona,
        assistantName: assistantName.isEmpty ? null : assistantName,
        // The AI speaks first with this line (empty = user speaks first).
        greeting: greeting.isEmpty ? null : Greeting.text(greeting),
        // Nudge the model toward brief, spoken-style replies; strips markdown/
        // emojis before TTS and enables [laughs]-style tags on ElevenLabs v3.
        naturalSpeech: _naturalSpeech,
        // Auto-end rules — say an end phrase, go silent, or hit the cap.
        policies: _buildPolicies(),
      ),
    );
  }

  SessionPolicies _buildPolicies() {
    final phrases = endPhrases.text
        .split(',')
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();
    final silence = int.tryParse(silenceSeconds.text.trim());
    final maxMin = int.tryParse(maxMinutes.text.trim());
    final endMsg = endMessage.text.trim();
    return SessionPolicies(
      endPhrases: phrases,
      endMessage: endMsg.isEmpty ? null : endMsg,
      silenceTimeout: silence == null ? null : Duration(seconds: silence),
      maxDuration: maxMin == null ? null : Duration(minutes: maxMin),
    );
  }

  void _set(VoidCallback change) {
    change();
    notifyListeners();
  }

  static TextEditingController _envField(String name) =>
      TextEditingController(text: String.fromEnvironment(name));

  @override
  void dispose() {
    for (final c in [
      groqKey,
      openAiKey,
      geminiKey,
      deepgramKey,
      elevenLabsKey,
      xaiKey,
      zaiKey,
      persona,
      assistantName,
      greeting,
      endPhrases,
      endMessage,
      silenceSeconds,
      maxMinutes,
    ]) {
      c.dispose();
    }
    super.dispose();
  }
}
