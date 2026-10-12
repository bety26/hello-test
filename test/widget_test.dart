import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hellotest/main.dart';
import 'package:hellotest/providers/notes_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Açılışta varsayılan alan görünür, not eklenebilir', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => NotesProvider()..init(),
        child: const NotDefteriApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Not Defteri'), findsOneWidget);
    expect(find.text('Genel'), findsOneWidget);
    expect(find.text('0 not'), findsOneWidget);

    // Alana girip not ekle
    await tester.tap(find.text('Genel'));
    await tester.pumpAndSettle();
    expect(find.textContaining('henüz not yok'), findsOneWidget);

    await tester.tap(find.text('Yeni not'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Başlık'), 'Alışveriş');
    await tester.enterText(
      find.widgetWithText(TextField, 'Notunuzu buraya yazın...'),
      'Süt, ekmek',
    );
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Alışveriş'), findsOneWidget);
    expect(find.text('Süt, ekmek'), findsOneWidget);
  });
}
