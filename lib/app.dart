import 'package:flutter/material.dart';

import 'features/setup/setup_page.dart';
import 'theme/app_theme.dart';

/// Root widget: wires the theme and the first screen. Kept intentionally thin —
/// all real work lives in the feature folders.
class VocraDemoApp extends StatelessWidget {
  const VocraDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vocra SDK Demo',
      theme: AppTheme.light(),
      home: const SetupPage(),
    );
  }
}
