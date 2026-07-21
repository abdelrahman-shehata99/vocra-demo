# vocra_demo

A demo app for the [Vocra](https://github.com/abdelrahman-shehata99/vocra) voice
AI SDK (`vocra`). Pick your providers (Groq/Gemini, Deepgram/ElevenLabs),
set a greeting and persona, and have a spoken conversation — all orchestrated
on-device.

It exercises the SDK's `greeting` (AI speaks first), `naturalSpeech` mode, and
the ElevenLabs model picker (including `eleven_v3` for `[laughs]`-style tags).

## Setup

This app depends on the SDK via a local path to the sibling `vocra` repo, so
clone both side by side:

```
your-code/
  vocra/         # the SDK
  vocra-demo/    # this app
```

```sh
flutter pub get
```

## Run

API keys are read from `--dart-define` (nothing is committed) and can also be
edited on the setup screen:

```sh
flutter run \
  --dart-define=GROQ_API_KEY=... \
  --dart-define=DEEPGRAM_API_KEY=... \
  --dart-define=ELEVENLABS_API_KEY=...   # only if you pick ElevenLabs
```

Deepgram is always required (it does the speech recognition). The other keys are
only needed for the providers you select.
