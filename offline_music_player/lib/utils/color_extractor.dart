import 'package:flutter/material.dart';

class ColorExtractor {
  static Color colorFromText(String value) {
    final hash = value.codeUnits.fold<int>(0, (sum, char) => sum + char);
    final colors = <Color>[
      const Color(0xFF1DB954),
      const Color(0xFFE94560),
      const Color(0xFF4D96FF),
      const Color(0xFFFFB703),
      const Color(0xFF9B5DE5),
      const Color(0xFF00B4D8),
    ];
    return colors[hash % colors.length];
  }
}
