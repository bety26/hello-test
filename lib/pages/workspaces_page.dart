import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/workspace.dart';
import '../providers/notes_provider.dart';
import 'notes_page.dart';

// Ana ekran: çalışma alanlarının listesi
class WorkspacesPage extends StatelessWidget {
  const WorkspacesPage({super.key});

  Future<String?> _askName(
    BuildContext context, {
    required String title,
    String initial = '',
  }) {
    final controller = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(hintText: 'Alan adı'),
          onSubmitted: (v) => Navigator.pop(ctx, v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  Future<void> _addWorkspace(BuildContext context) async {
    final provider = context.read<NotesProvider>();
    final name = await _askName(context, title: 'Yeni alan');
    if (name != null) await provider.addWorkspace(name);
  }

  Future<void> _rename(BuildContext context, Workspace workspace) async {
    final provider = context.read<NotesProvider>();
    final name = await _askName(
      context,
      title: 'Alanı yeniden adlandır',
      initial: workspace.name,
    );
    if (name != null) await provider.renameWorkspace(workspace.id, name);
  }

  Future<void> _delete(BuildContext context, Workspace workspace) async {
    final provider = context.read<NotesProvider>();
    final messenger = ScaffoldMessenger.of(context);

    if (provider.workspaces.length <= 1) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Son kalan alan silinemez.')),
      );
      return;
    }

    final count = provider.noteCount(workspace.id);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Alanı sil'),
        content: Text(
          count == 0
              ? '"${workspace.name}" alanı silinecek.'
              : '"${workspace.name}" alanı ve içindeki $count not kalıcı olarak silinecek.',
        ),
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
    if (ok == true) await provider.deleteWorkspace(workspace.id);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotesProvider>();
    final workspaces = provider.workspaces;

    return Scaffold(
      appBar: AppBar(title: const Text('Not Defteri')),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: workspaces.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final w = workspaces[i];
          final count = provider.noteCount(w.id);
          return Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              leading: const Icon(Icons.folder_outlined),
              title: Text(
                w.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text('$count not'),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'rename') _rename(context, w);
                  if (value == 'delete') _delete(context, w);
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'rename', child: Text('Yeniden adlandır')),
                  PopupMenuItem(value: 'delete', child: Text('Sil')),
                ],
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => NotesPage(workspaceId: w.id)),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addWorkspace(context),
        icon: const Icon(Icons.create_new_folder_outlined),
        label: const Text('Yeni alan'),
      ),
    );
  }
}
