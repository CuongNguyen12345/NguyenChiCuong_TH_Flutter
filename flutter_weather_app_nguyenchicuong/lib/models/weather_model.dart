class WeatherModel {
  final String cityName;
  final String country;
  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final int windDegree;
  final int pressure;
  final String description;
  final String icon;
  final String mainCondition;
  final DateTime dateTime;
  final double? tempMin;
  final double? tempMax;
  final int? visibility;
  final int? cloudiness;
  final double? uvIndex;
  final DateTime? sunrise;
  final DateTime? sunset;

  WeatherModel({
    required this.cityName,
    required this.country,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.windDegree,
    required this.pressure,
    required this.description,
    required this.icon,
    required this.mainCondition,
    required this.dateTime,
    this.tempMin,
    this.tempMax,
    this.visibility,
    this.cloudiness,
    this.uvIndex,
    this.sunrise,
    this.sunset,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      cityName: json['name']?.toString() ?? 'Unknown',
      country: json['sys']?['country']?.toString() ?? '--',
      temperature: (json['main']?['temp'] as num?)?.toDouble() ?? 0,
      feelsLike: (json['main']?['feels_like'] as num?)?.toDouble() ?? 0,
      humidity: (json['main']?['humidity'] as num?)?.toInt() ?? 0,
      windSpeed: (json['wind']?['speed'] as num?)?.toDouble() ?? 0,
      windDegree: (json['wind']?['deg'] as num?)?.toInt() ?? 0,
      pressure: (json['main']?['pressure'] as num?)?.toInt() ?? 0,
      description: json['weather']?[0]?['description']?.toString() ?? 'N/A',
      icon: json['weather']?[0]?['icon']?.toString() ?? '01d',
      mainCondition: json['weather']?[0]?['main']?.toString() ?? 'Clear',
      dateTime: DateTime.fromMillisecondsSinceEpoch(
        ((json['dt'] as num?)?.toInt() ?? DateTime.now().millisecondsSinceEpoch ~/ 1000) * 1000,
      ),
      tempMin: (json['main']?['temp_min'] as num?)?.toDouble(),
      tempMax: (json['main']?['temp_max'] as num?)?.toDouble(),
      visibility: (json['visibility'] as num?)?.toInt(),
      cloudiness: (json['clouds']?['all'] as num?)?.toInt(),
      uvIndex: (json['uvi'] as num?)?.toDouble(),
      sunrise: json['sys']?['sunrise'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch((json['sys']['sunrise'] as int) * 1000),
      sunset: json['sys']?['sunset'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch((json['sys']['sunset'] as int) * 1000),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': cityName,
      'sys': {
        'country': country,
        'sunrise': sunrise?.millisecondsSinceEpoch != null
            ? sunrise!.millisecondsSinceEpoch ~/ 1000
            : null,
        'sunset': sunset?.millisecondsSinceEpoch != null
            ? sunset!.millisecondsSinceEpoch ~/ 1000
            : null,
      },
      'main': {
        'temp': temperature,
        'feels_like': feelsLike,
        'humidity': humidity,
        'pressure': pressure,
        'temp_min': tempMin,
        'temp_max': tempMax,
      },
      'wind': {
        'speed': windSpeed,
        'deg': windDegree,
      },
      'weather': [
        {
          'description': description,
          'icon': icon,
          'main': mainCondition,
        }
      ],
      'dt': dateTime.millisecondsSinceEpoch ~/ 1000,
      'visibility': visibility,
      'clouds': {'all': cloudiness},
      'uvi': uvIndex,
    };
  }
}
