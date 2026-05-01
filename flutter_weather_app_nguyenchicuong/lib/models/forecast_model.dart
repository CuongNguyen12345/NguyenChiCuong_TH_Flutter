class ForecastModel {
  final DateTime dateTime;
  final double temperature;
  final String description;
  final String icon;
  final double tempMin;
  final double tempMax;
  final int humidity;
  final double windSpeed;
  final double precipitationProbability;

  ForecastModel({
    required this.dateTime,
    required this.temperature,
    required this.description,
    required this.icon,
    required this.tempMin,
    required this.tempMax,
    required this.humidity,
    required this.windSpeed,
    required this.precipitationProbability,
  });

  factory ForecastModel.fromJson(Map<String, dynamic> json) {
    return ForecastModel(
      dateTime: DateTime.fromMillisecondsSinceEpoch((json['dt'] as int) * 1000),
      temperature: (json['main']?['temp'] as num).toDouble(),
      description: json['weather'][0]['description'] as String,
      icon: json['weather'][0]['icon'] as String,
      tempMin: (json['main']?['temp_min'] as num).toDouble(),
      tempMax: (json['main']?['temp_max'] as num).toDouble(),
      humidity: (json['main']?['humidity'] as num).toInt(),
      windSpeed: (json['wind']?['speed'] as num).toDouble(),
      precipitationProbability: (json['pop'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dt': dateTime.millisecondsSinceEpoch ~/ 1000,
      'main': {
        'temp': temperature,
        'temp_min': tempMin,
        'temp_max': tempMax,
        'humidity': humidity,
      },
      'weather': [
        {'description': description, 'icon': icon}
      ],
      'wind': {'speed': windSpeed},
      'pop': precipitationProbability,
    };
  }
}
