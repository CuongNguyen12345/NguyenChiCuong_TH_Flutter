import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool _useDynamicArtworkTheme = true;

  bool get useDynamicArtworkTheme => _useDynamicArtworkTheme;

  void toggleDynamicArtworkTheme(bool value) {
    _useDynamicArtworkTheme = value;
    notifyListeners();
  }
}
