enum CalculatorMode { basic, scientific, programmer }

extension CalculatorModeX on CalculatorMode {
  String get label {
    switch (this) {
      case CalculatorMode.basic:
        return 'Basic';
      case CalculatorMode.scientific:
        return 'Scientific';
      case CalculatorMode.programmer:
        return 'Programmer';
    }
  }
}

enum AngleMode { degrees, radians }

extension AngleModeX on AngleMode {
  String get label => this == AngleMode.degrees ? 'DEG' : 'RAD';
}
