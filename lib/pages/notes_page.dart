import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/notes_provider.dart';
import '../widgets/note_card.dart';
import 'note_edit_page.dart';

// Seçili alandaki notların renkli kartlar halinde listelendiği ekran
class NotesPage extends StatefulWidget {
  final String workspaceId;

  const NotesPage({super.key, required this.workspaceId});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _searching = false;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openNote({dynamic note}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            NoteEditPage(workspaceId: widget.workspaceId, note: note),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotesProvider>();
    final workspace = provider.workspaceById(widget.workspaceId);
    final notes = provider.notesOf(widget.workspaceId, query: _query);

    return Scaffold(
      appBar: AppBar(
        title: _searching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Notlarda ara...',
                  border: InputBorder.none,
                ),
                onChanged: (v) => setState(() => _query = v),
              )
            : Text(workspace?.name ?? 'Notlar'),
        actions: [
          IconButton(
            tooltip: _searching ? 'Aramayı kapat' : 'Ara',
            icon: Icon(_searching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _searching = !_searching;
                if (!_searching) {
                  _query = '';
                  _searchController.clear();
                }
              });
            },
          ),
        ],
      ),
      body: notes.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  _query.isNotEmpty
                      ? 'Aramanızla eşleşen not bulunamadı.'
                      : 'Bu alanda henüz not yok.\nYeni not eklemek için + düğmesine dokunun.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.95,
              ),
              itemCount: notes.length,
              itemBuilder: (context, i) => NoteCard(
                note: notes[i],
                onTap: () => _openNote(note: notes[i]),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openNote(),
        icon: const Icon(Icons.add),
        label: const Text('Yeni not'),
      ),
    );
  }
}
