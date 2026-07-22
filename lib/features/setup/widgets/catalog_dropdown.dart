import 'package:flutter/material.dart';
import 'package:vocra_flutter/vocra_flutter.dart';

/// One generic dropdown for ANY of the SDK's typed catalogs
/// (`GroqModel.values`, `DeepgramVoice.values`, …) — they all implement
/// [CatalogEntry].
class CatalogDropdown<T extends CatalogEntry> extends StatelessWidget {
  const CatalogDropdown({
    super.key,
    required this.label,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final List<T> options;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      items: [
        for (final o in options)
          DropdownMenuItem(
            value: o,
            child: Text(
              o.note == null ? o.displayName : '${o.displayName} — ${o.note}',
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
      onChanged: (v) => onChanged(v!),
    );
  }
}
