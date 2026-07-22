/// Small formatting helpers shared across screens.
abstract final class Format {
  /// Renders a latency [Duration] as milliseconds, or `—` when absent.
  static String ms(Duration? d) => d == null ? '—' : '${d.inMilliseconds}ms';
}
