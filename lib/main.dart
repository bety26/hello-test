import 'package:flutter/material.dart';

void main() => runApp(const HelloApp());

class HelloApp extends StatelessWidget {
  const HelloApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Hello Test',
      home: Scaffold(
        body: Center(
          child: Text('Merhaba Dünya', style: TextStyle(fontSize: 28)),
        ),
      ),
    );
  }
}
