import 'package:flutter/material.dart';

/// Central place for the app's visual identity so screens never hard-code
/// their own [ThemeData].
abstract final class AppTheme {
  static ThemeData light() => ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
    useMaterial3: true,
  );
}
