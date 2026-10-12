import 'package:flutter/material.dart';

// "#RRGGBB" biçimindeki renk metnini Color'a çevirir
Color colorFromHex(String hex) {
  var value = hex.replaceAll('#', '');
  if (value.length == 6) value = 'FF$value';
  final parsed = int.tryParse(value, radix: 16);
  return Color(parsed ?? 0xFFFFD68A);
}

// 05.10.2026 14:30 biçiminde tarih
String formatDateTime(DateTime date) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(date.day)}.${two(date.month)}.${date.year} '
      '${two(date.hour)}:${two(date.minute)}';
}
