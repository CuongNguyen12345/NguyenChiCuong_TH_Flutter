import 'package:flutter/material.dart';

import '../utils/constants.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeProvider({ThemeMode initialThemeMode = ThemeMode.system})
      : _themeMode = initialThemeMode;

  ThemeMode _themeMode;

  ThemeMode get themeMode => _themeMode;

  ThemeData get lightTheme => AppThemes.lightTheme;
  ThemeData get darkTheme => AppThemes.darkTheme;

  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) {
      return;
    }
    _themeMode = mode;
    notifyListeners();
  }

  void toggleTheme() {
    setThemeMode(_themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
  }
}
