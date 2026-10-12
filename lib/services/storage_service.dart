import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/note.dart';
import '../models/workspace.dart';

// Alanları ve notları cihazda JSON olarak saklar (internet kullanılmaz)
class StorageService {
  static const String _workspacesKey = 'workspaces_v1';
  static const String _notesKey = 'notes_v1';

  Future<List<Workspace>> loadWorkspaces() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_workspacesKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => Workspace.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // Bozuk kayıt uygulamayı çökertmesin
      return [];
    }
  }

  Future<List<Note>> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_notesKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => Note.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveWorkspaces(List<Workspace> workspaces) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _workspacesKey,
      jsonEncode(workspaces.map((w) => w.toJson()).toList()),
    );
  }

  Future<void> saveNotes(List<Note> notes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _notesKey,
      jsonEncode(notes.map((n) => n.toJson()).toList()),
    );
  }
}
