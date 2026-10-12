import 'package:flutter/material.dart';

import '../models/note.dart';
import '../utils/format_utils.dart';

// Not rengi seçici: 8 renkli daire
class ColorPicker extends StatelessWidget {
  final String selectedHex;
  final ValueChanged<String> onSelected;

  const ColorPicker({
    super.key,
    required this.selectedHex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: kNoteColors.map((hex) {
        final selected = hex == selectedHex;
        return GestureDetector(
          onTap: () => onSelected(hex),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colorFromHex(hex),
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? Colors.black87 : Colors.black26,
                width: selected ? 3 : 1,
              ),
            ),
            child: selected
                ? const Icon(Icons.check, size: 18, color: Colors.black87)
                : null,
          ),
        );
      }).toList(),
    );
  }
}
