import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/note.dart';
import '../providers/notes_provider.dart';
import '../utils/format_utils.dart';
import '../widgets/color_picker.dart';

// Yeni not oluşturma veya var olan notu düzenleme ekranı.
// Sayfadan geri dönüldüğünde not otomatik kaydedilir.
class NoteEditPage extends StatefulWidget {
  final String workspaceId;
  final Note? note;

  const NoteEditPage({super.key, required this.workspaceId, this.note});

  @override
  State<NoteEditPage> createState() => _NoteEditPageState();
}

class _NoteEditPageState extends State<NoteEditPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late String _colorHex;
  late double _fontSize;
  late bool _isPinned;
  late String _workspaceId;

  // Yeni not ilk kez kaydedildikten sonra güncelleme olarak devam eder
  Note? _savedNote;
  bool _deleted = false;

  @override
  void initState() {
    super.initState();
    final note = widget.note;
    _savedNote = note;
    _titleController = TextEditingController(text: note?.title ?? '');
    _contentController = TextEditingController(text: note?.content ?? '');
    _colorHex = note?.colorHex ?? kNoteColors.first;
    _fontSize = note?.fontSize ?? kDefaultNoteFontSize;
    _isPinned = note?.isPinned ?? false;
    _workspaceId = note?.workspaceId ?? widget.workspaceId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_deleted) return;
    final provider = context.read<NotesProvider>();
    final title = _titleController.text;
    final content = _contentController.text;
    final existing = _savedNote;

    if (existing == null) {
      // Boş yeni not kaydedilmez
      if (title.trim().isEmpty && content.trim().isEmpty) return;
      _savedNote = await provider.createNote(
        workspaceId: _workspaceId,
        title: title,
        content: content,
        colorHex: _colorHex,
        fontSize: _fontSize,
        isPinned: _isPinned,
      );
    } else {
      await provider.updateNote(
        existing.copyWith(
          workspaceId: _workspaceId,
          title: title,
          content: content,
          colorHex: _colorHex,
          fontSize: _fontSize,
          isPinned: _isPinned,
        ),
      );
    }
  }

  Future<void> _confirmDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Notu sil'),
        content: const Text('Bu not kalıcı olarak silinecek. Emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final existing = _savedNote;
    if (existing != null) {
      await context.read<NotesProvider>().deleteNote(existing.id);
    }
    _deleted = true;
    if (mounted) Navigator.pop(context);
  }

  Future<void> _pickWorkspace() async {
    final provider = context.read<NotesProvider>();
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Notu taşı',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ...provider.workspaces.map(
              (w) => ListTile(
                leading: Icon(
                  w.id == _workspaceId
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                ),
                title: Text(w.name),
                onTap: () => Navigator.pop(ctx, w.id),
              ),
            ),
          ],
        ),
      ),
    );
    if (selected != null && mounted) {
      setState(() => _workspaceId = selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotesProvider>();
    final workspace = provider.workspaceById(_workspaceId);
    final background = colorFromHex(_colorHex);

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) _save();
      },
      child: Scaffold(
        backgroundColor: background,
        appBar: AppBar(
          backgroundColor: background,
          foregroundColor: Colors.black87,
          elevation: 0,
          title: Text(
            widget.note == null ? 'Yeni not' : 'Notu düzenle',
            style: const TextStyle(fontSize: 18),
          ),
          actions: [
            IconButton(
              tooltip: _isPinned ? 'Sabitlemeyi kaldır' : 'Sabitle',
              icon: Icon(_isPinned ? Icons.push_pin : Icons.push_pin_outlined),
              onPressed: () => setState(() => _isPinned = !_isPinned),
            ),
            IconButton(
              tooltip: 'Başka alana taşı',
              icon: const Icon(Icons.drive_file_move_outline),
              onPressed: _pickWorkspace,
            ),
            if (_savedNote != null)
              IconButton(
                tooltip: 'Sil',
                icon: const Icon(Icons.delete_outline),
                onPressed: _confirmDelete,
              ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (workspace != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Alan: ${workspace.name}',
                    style: const TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                ),
              TextField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                decoration: const InputDecoration(
                  hintText: 'Başlık',
                  border: InputBorder.none,
                ),
              ),
              const Divider(height: 1, color: Colors.black26),
              Expanded(
                child: TextField(
                  controller: _contentController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  textCapitalization: TextCapitalization.sentences,
                  style: TextStyle(fontSize: _fontSize, color: Colors.black87),
                  decoration: const InputDecoration(
                    hintText: 'Notunuzu buraya yazın...',
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ColorPicker(
                selectedHex: _colorHex,
                onSelected: (hex) => setState(() => _colorHex = hex),
              ),
              Row(
                children: [
                  const Icon(Icons.text_fields, color: Colors.black54),
                  Expanded(
                    child: Slider(
                      min: kMinNoteFontSize,
                      max: kMaxNoteFontSize,
                      divisions: (kMaxNoteFontSize - kMinNoteFontSize).toInt(),
                      value: _fontSize.clamp(kMinNoteFontSize, kMaxNoteFontSize),
                      label: _fontSize.round().toString(),
                      onChanged: (v) => setState(() => _fontSize = v),
                    ),
                  ),
                  Text(
                    _fontSize.round().toString(),
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
