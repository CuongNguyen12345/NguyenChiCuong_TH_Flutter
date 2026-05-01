class HourlyWeatherModel {
  final DateTime dateTime;
  final double temperature;
  final String icon;
  final String condition;
  final double precipitationProbability;

  HourlyWeatherModel({
    required this.dateTime,
    required this.temperature,
    required this.icon,
    required this.condition,
    required this.precipitationProbability,
  });

  factory HourlyWeatherModel.fromJson(Map<String, dynamic> json) {
    return HourlyWeatherModel(
      dateTime: DateTime.fromMillisecondsSinceEpoch((json['dt'] as int) * 1000),
      temperature: (json['temp'] as num).toDouble(),
      icon: json['icon'] as String,
      condition: json['condition'] as String,
      precipitationProbability: (json['pop'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dt': dateTime.millisecondsSinceEpoch ~/ 1000,
      'temp': temperature,
      'icon': icon,
      'condition': condition,
      'pop': precipitationProbability,
    };
  }
}
