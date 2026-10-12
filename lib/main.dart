import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'pages/workspaces_page.dart';
import 'providers/notes_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => NotesProvider()..init(),
      child: const NotDefteriApp(),
    ),
  );
}

class NotDefteriApp extends StatelessWidget {
  const NotDefteriApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Not Defteri',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFFB300)),
      ),
      home: const _Root(),
    );
  }
}

// Veriler yüklenene kadar bekleme göstergesi, sonra ana ekran
class _Root extends StatelessWidget {
  const _Root();

  @override
  Widget build(BuildContext context) {
    final loaded = context.select<NotesProvider, bool>((p) => p.isLoaded);
    if (!loaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return const WorkspacesPage();
  }
}
