import 'package:flutter/foundation.dart';
import 'package:vocra_flutter/vocra_flutter.dart';

/// Wraps a [VocraSession] and exposes its live streams as plain listenable
/// fields, so the UI can `ListenableBuilder` over just what it needs instead of
/// calling `setState` on the whole page for every transcript tick.
///
/// The controller owns the session's lifecycle: it subscribes in the
/// constructor and disposes everything in [dispose].
class ConversationController extends ChangeNotifier {
  ConversationController(this._session) {
    // One observe() call — the SDK hands back the already-merged conversation.
    _sub = _session.observe(
      onState: (s) => _update(() => _state = s),
      onMetrics: (m) => _update(() => _metrics = m),
      onError: (e) => _update(() => _error = e.message),
      onMessages: (messages) => _update(() => _transcript = messages),
    );
    // The session can end itself (end phrase, silence, or max duration); expose
    // that report to whoever is listening.
    _session.sessionEnded.first.then((report) {
      _lastReport = report;
      if (!_disposed) notifyListeners();
    });
  }

  final VocraSession _session;
  VocraSubscription? _sub;
  bool _disposed = false;

  TurnState _state = TurnState.idle;
  List<TranscriptEvent> _transcript = const [];
  TurnMetrics? _metrics;
  String? _error;
  bool _busy = false;
  bool _muted = false;
  SessionReport? _lastReport;

  TurnState get state => _state;
  List<TranscriptEvent> get transcript => _transcript;
  TurnMetrics? get metrics => _metrics;
  String? get error => _error;
  bool get busy => _busy;
  bool get muted => _muted;

  /// A session-ended report the UI hasn't shown yet, or null. The caller marks
  /// it handled with [consumeReport].
  SessionReport? get pendingReport => _lastReport;

  /// True while a turn is active (listening, thinking, or speaking).
  bool get isLive => _state != TurnState.idle;

  /// Starts the mic when idle, stops the active turn when live.
  Future<void> toggleMic() async {
    if (isLive) {
      await _session.stop();
      return;
    }
    _update(() => _busy = true);
    try {
      await _session.requestPermissions();
      await _session.start();
    } catch (e) {
      _update(() => _error = 'start failed: $e');
    } finally {
      _update(() => _busy = false);
    }
  }

  void toggleMute() {
    _muted = !_muted;
    _muted ? _session.mute() : _session.unmute();
    notifyListeners();
  }

  Future<void> sendText(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    await _session.sendText(trimmed);
  }

  /// Ends the session and returns its report, or null if not live.
  Future<SessionReport?> endSession() async {
    if (!isLive) return null;
    try {
      return await _session.endSession();
    } catch (e) {
      _update(() => _error = 'endSession failed: $e');
      return null;
    }
  }

  /// Returns the pending self-ended report (if any) and clears it.
  SessionReport? consumeReport() {
    final report = _lastReport;
    _lastReport = null;
    return report;
  }

  void _update(VoidCallback change) {
    if (_disposed) return;
    change();
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _sub?.cancel();
    _session.dispose();
    super.dispose();
  }
}
