import 'package:flutter_test/flutter_test.dart';
import 'package:hellotest/models/note.dart';
import 'package:hellotest/providers/notes_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<NotesProvider> _newProvider() async {
  SharedPreferences.setMockInitialValues({});
  final provider = NotesProvider();
  await provider.init();
  return provider;
}

void main() {
  test('Not JSON gidiş dönüş', () {
    final now = DateTime(2026, 10, 12, 9, 30);
    final note = Note(
      id: '1',
      workspaceId: 'w',
      title: 'Başlık',
      content: 'İçerik',
      colorHex: '#A8E6CF',
      fontSize: 18,
      isPinned: true,
      createdAt: now,
      updatedAt: now,
    );
    final copy = Note.fromJson(note.toJson());
    expect(copy.title, 'Başlık');
    expect(copy.content, 'İçerik');
    expect(copy.colorHex, '#A8E6CF');
    expect(copy.fontSize, 18);
    expect(copy.isPinned, true);
    expect(copy.createdAt, now);
  });

  test('İlk açılışta Genel alanı oluşur', () async {
    final p = await _newProvider();
    expect(p.workspaces.length, 1);
    expect(p.workspaces.first.name, 'Genel');
  });

  test('Sabitlenen not listede üstte, arama çalışır', () async {
    final p = await _newProvider();
    final ws = p.workspaces.first.id;
    final a = await p.createNote(
      workspaceId: ws, title: 'Elma', content: '', colorHex: kNoteColors.first,
      fontSize: 16, isPinned: false,
    );
    await p.createNote(
      workspaceId: ws, title: 'Armut', content: 'meyve', colorHex: kNoteColors.first,
      fontSize: 16, isPinned: false,
    );
    await p.togglePin(a.id);

    expect(p.notesOf(ws).first.title, 'Elma');
    expect(p.notesOf(ws, query: 'meyve').length, 1);
    expect(p.notesOf(ws, query: 'ELMA').length, 1);
  });

  test('Alan silinince notları da silinir, son alan silinemez', () async {
    final p = await _newProvider();
    await p.addWorkspace('İş');
    final work = p.workspaces.last.id;
    await p.createNote(
      workspaceId: work, title: 'Toplantı', content: '', colorHex: kNoteColors.first,
      fontSize: 16, isPinned: false,
    );
    expect(p.noteCount(work), 1);

    expect(await p.deleteWorkspace(work), true);
    expect(p.noteCount(work), 0);
    expect(p.workspaces.length, 1);

    // Tek alan kaldı: silinemez
    expect(await p.deleteWorkspace(p.workspaces.first.id), false);
  });

  test('Not başka alana taşınır', () async {
    final p = await _newProvider();
    await p.addWorkspace('Kişisel');
    final from = p.workspaces.first.id;
    final to = p.workspaces.last.id;
    final n = await p.createNote(
      workspaceId: from, title: 'Not', content: '', colorHex: kNoteColors.first,
      fontSize: 16, isPinned: false,
    );
    await p.moveNote(n.id, to);
    expect(p.noteCount(from), 0);
    expect(p.noteCount(to), 1);
  });
}
