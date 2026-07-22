import 'package:flutter/material.dart';

import 'app.dart';

// Re-exported so `import 'package:vocra_demo/main.dart'` keeps exposing
// [VocraDemoApp] (used by the widget test) after the app was split into files.
export 'app.dart';

void main() => runApp(const VocraDemoApp());
