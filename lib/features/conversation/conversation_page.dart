import 'package:flutter/material.dart';
import 'package:vocra_flutter/vocra_flutter.dart';

import 'conversation_controller.dart';
import 'widgets/composer.dart';
import 'widgets/error_banner.dart';
import 'widgets/metrics_bar.dart';
import 'widgets/session_report_dialog.dart';
import 'widgets/status_banner.dart';
import 'widgets/transcript_view.dart';

/// Step 2: drive the session and render its streams.
///
/// All session state lives in [ConversationController]; this widget owns its
/// lifecycle, surfaces the end-of-session report, and lays out the pieces.
class ConversationPage extends StatefulWidget {
  const ConversationPage({super.key, required this.session});

  final VocraSession session;

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  late final ConversationController _controller = ConversationController(
    widget.session,
  )..addListener(_onSelfEnded);

  // The session can be ended manually and can also end itself; guard so the
  // report is only ever shown once.
  bool _reportShown = false;

  @override
  void dispose() {
    _controller.removeListener(_onSelfEnded);
    _controller.dispose();
    super.dispose();
  }

  /// Shows the report when the session ends on its own.
  void _onSelfEnded() {
    final report = _controller.consumeReport();
    if (report != null) _showReport(report);
  }

  Future<void> _endSession() async {
    final report = await _controller.endSession();
    if (report != null) _showReport(report);
  }

  void _showReport(SessionReport report) {
    if (_reportShown || !mounted) return;
    _reportShown = true;
    SessionReportDialog.show(context, report);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversation'),
        actions: [
          ListenableBuilder(
            listenable: _controller,
            builder: (context, _) => Row(
              children: [
                IconButton(
                  tooltip: _controller.muted ? 'Unmute' : 'Mute',
                  icon: Icon(_controller.muted ? Icons.mic_off : Icons.mic),
                  onPressed: _controller.isLive ? _controller.toggleMute : null,
                ),
                IconButton(
                  tooltip: 'End session',
                  icon: const Icon(Icons.call_end),
                  onPressed: _controller.isLive ? _endSession : null,
                ),
              ],
            ),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          final error = _controller.error;
          final metrics = _controller.metrics;
          return Column(
            children: [
              StatusBanner(state: _controller.state),
              if (error != null) ErrorBanner(message: error),
              if (metrics != null) MetricsBar(metrics: metrics),
              Expanded(
                child: TranscriptView(transcript: _controller.transcript),
              ),
              Composer(
                busy: _controller.busy,
                isLive: _controller.isLive,
                onSend: _controller.sendText,
                onToggleMic: _controller.toggleMic,
              ),
            ],
          );
        },
      ),
    );
  }
}
