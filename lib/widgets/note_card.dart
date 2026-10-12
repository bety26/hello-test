import 'package:flutter/material.dart';

import '../models/note.dart';
import '../utils/format_utils.dart';

// Panodaki tek bir renkli not kağıdı
class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;

  const NoteCard({super.key, required this.note, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasTitle = note.title.trim().isNotEmpty;
    return Material(
      color: colorFromHex(note.colorHex),
      elevation: 2,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      hasTitle ? note.title : 'Başlıksız not',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.black87,
                        fontStyle: hasTitle ? FontStyle.normal : FontStyle.italic,
                      ),
                    ),
                  ),
                  if (note.isPinned)
                    const Icon(Icons.push_pin, size: 16, color: Colors.black54),
                ],
              ),
              const SizedBox(height: 6),
              Expanded(
                child: Text(
                  note.content,
                  overflow: TextOverflow.fade,
                  style: TextStyle(
                    fontSize: note.fontSize.clamp(12, 16).toDouble(),
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                formatDateTime(note.updatedAt),
                style: const TextStyle(fontSize: 11, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
