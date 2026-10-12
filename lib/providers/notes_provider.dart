import 'package:flutter/foundation.dart';

import '../models/note.dart';
import '../models/workspace.dart';
import '../services/storage_service.dart';

// Alanların ve notların uygulama genelindeki durumu
class NotesProvider extends ChangeNotifier {
  NotesProvider({StorageService? storage}) : _storage = storage ?? StorageService();

  static const String defaultWorkspaceName = 'Genel';

  final StorageService _storage;
  List<Workspace> _workspaces = [];
  List<Note> _notes = [];
  bool _isLoaded = false;
  int _idCounter = 0;

  bool get isLoaded => _isLoaded;
  List<Workspace> get workspaces => List.unmodifiable(_workspaces);

  Future<void> init() async {
    _workspaces = await _storage.loadWorkspaces();
    _notes = await _storage.loadNotes();

    // İlk açılışta en az bir alan olsun
    if (_workspaces.isEmpty) {
      _workspaces = [
        Workspace(id: _newId(), name: defaultWorkspaceName, order: 0),
      ];
      await _storage.saveWorkspaces(_workspaces);
    }
    _workspaces.sort((a, b) => a.order.compareTo(b.order));
    _isLoaded = true;
    notifyListeners();
  }

  String _newId() {
    _idCounter++;
    return '${DateTime.now().microsecondsSinceEpoch}_$_idCounter';
  }

  Workspace? workspaceById(String id) {
    for (final w in _workspaces) {
      if (w.id == id) return w;
    }
    return null;
  }

  int noteCount(String workspaceId) =>
      _notes.where((n) => n.workspaceId == workspaceId).length;

  // Bir alandaki notlar: sabitlenenler üstte, sonra en son düzenlenen
  List<Note> notesOf(String workspaceId, {String query = ''}) {
    final q = query.trim().toLowerCase();
    final list = _notes.where((n) {
      if (n.workspaceId != workspaceId) return false;
      if (q.isEmpty) return true;
      return n.title.toLowerCase().contains(q) ||
          n.content.toLowerCase().contains(q);
    }).toList();
    list.sort((a, b) {
      if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
      return b.updatedAt.compareTo(a.updatedAt);
    });
    return list;
  }

  Note? noteById(String id) {
    for (final n in _notes) {
      if (n.id == id) return n;
    }
    return null;
  }

  // --- Alan işlemleri ---

  Future<void> addWorkspace(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    final nextOrder = _workspaces.isEmpty
        ? 0
        : _workspaces.map((w) => w.order).reduce((a, b) => a > b ? a : b) + 1;
    _workspaces = [
      ..._workspaces,
      Workspace(id: _newId(), name: trimmed, order: nextOrder),
    ];
    await _storage.saveWorkspaces(_workspaces);
    notifyListeners();
  }

  Future<void> renameWorkspace(String id, String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    _workspaces = _workspaces
        .map((w) => w.id == id ? w.copyWith(name: trimmed) : w)
        .toList();
    await _storage.saveWorkspaces(_workspaces);
    notifyListeners();
  }

  // Alan silinince içindeki notlar da silinir. Son kalan alan silinemez.
  Future<bool> deleteWorkspace(String id) async {
    if (_workspaces.length <= 1) return false;
    _workspaces = _workspaces.where((w) => w.id != id).toList();
    _notes = _notes.where((n) => n.workspaceId != id).toList();
    await _storage.saveWorkspaces(_workspaces);
    await _storage.saveNotes(_notes);
    notifyListeners();
    return true;
  }

  // --- Not işlemleri ---

  Future<Note> createNote({
    required String workspaceId,
    required String title,
    required String content,
    required String colorHex,
    required double fontSize,
    required bool isPinned,
  }) async {
    final now = DateTime.now();
    final note = Note(
      id: _newId(),
      workspaceId: workspaceId,
      title: title,
      content: content,
      colorHex: colorHex,
      fontSize: fontSize,
      isPinned: isPinned,
      createdAt: now,
      updatedAt: now,
    );
    _notes = [..._notes, note];
    await _storage.saveNotes(_notes);
    notifyListeners();
    return note;
  }

  Future<void> updateNote(Note updated) async {
    final changed = updated.copyWith(updatedAt: DateTime.now());
    _notes = _notes.map((n) => n.id == updated.id ? changed : n).toList();
    await _storage.saveNotes(_notes);
    notifyListeners();
  }

  Future<void> deleteNote(String id) async {
    _notes = _notes.where((n) => n.id != id).toList();
    await _storage.saveNotes(_notes);
    notifyListeners();
  }

  Future<void> togglePin(String id) async {
    final note = noteById(id);
    if (note == null) return;
    await updateNote(note.copyWith(isPinned: !note.isPinned));
  }

  Future<void> moveNote(String id, String targetWorkspaceId) async {
    final note = noteById(id);
    if (note == null) return;
    await updateNote(note.copyWith(workspaceId: targetWorkspaceId));
  }
}
