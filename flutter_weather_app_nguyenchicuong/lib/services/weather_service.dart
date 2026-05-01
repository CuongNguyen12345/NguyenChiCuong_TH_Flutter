import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/forecast_model.dart';
import '../models/hourly_weather_model.dart';
import '../models/weather_model.dart';

class WeatherService {
  final String apiKey;
  // final bool useMockData;
  final http.Client _client;

  WeatherService({
    String? apiKey,
    // this.useMockData = true,
    http.Client? client,
  }) : apiKey = apiKey ?? ApiConfig.apiKey,
       _client = client ?? http.Client();

  static const List<String> _knownCities = [
    'Ho Chi Minh City',
    'Hanoi',
    'Da Nang',
    'London',
    'New York',
    'Tokyo',
    'Paris',
    'Singapore',
    'Bangkok',
    'Sydney',
  ];

  Future<WeatherModel> getCurrentWeatherByCity(String cityName) async {
    if (cityName.trim().isEmpty) {
      throw Exception('Please enter a city name');
    }

    // if (useMockData) {
    //   await Future<void>.delayed(const Duration(milliseconds: 700));
    //   final normalized = _normalize(cityName);
    //   if (normalized == 'invalidcity' || normalized == '404') {
    //     throw Exception('City not found');
    //   }
    //   return _buildCurrentWeather(cityName: cityName);
    // }

    _assertApiKey();
    final payload = await _getForecastPayload(query: cityName, days: 1);
    return _mapCurrentWeather(payload);
  }

  Future<WeatherModel> getCurrentWeatherByCoordinates(
    double lat,
    double lon,
  ) async {
    // if (useMockData) {
    //   await Future<void>.delayed(const Duration(milliseconds: 700));
    //   final city = lat >= 0 ? 'Hanoi' : 'Ho Chi Minh City';
    //   return _buildCurrentWeather(cityName: city, latitude: lat, longitude: lon);
    // }

    _assertApiKey();
    final payload = await _getForecastPayload(query: '$lat,$lon', days: 1);
    return _mapCurrentWeather(payload);
  }

  Future<List<ForecastModel>> getForecast(String cityName) async {
    // if (useMockData) {
    //   await Future<void>.delayed(const Duration(milliseconds: 450));
    //   return _buildForecast(cityName);
    // }

    _assertApiKey();
    final payload = await _getForecastPayload(query: cityName, days: 7);
    return _mapForecastSlots(payload);
  }

  Future<List<HourlyWeatherModel>> getHourlyForecast(
    String cityName, {
    int hours = 24,
  }) async {
    // if (useMockData) {
    //   await Future<void>.delayed(const Duration(milliseconds: 450));
    //   return _buildHourly(cityName, hours);
    // }

    _assertApiKey();
    final days = (hours / 24).ceil() + 1;
    final payload = await _getForecastPayload(
      query: cityName,
      days: days.clamp(1, 10),
    );
    return _mapHourlyForecast(payload, hours);
  }

  Future<List<String>> searchCities(String query) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));

    // if (useMockData) {
    //   final normalized = _normalize(query);
    //   if (normalized.isEmpty) {
    //     return _knownCities;
    //   }
    //   return _knownCities.where((city) => _normalize(city).contains(normalized)).toList();
    // }

    _assertApiKey();
    if (query.trim().isEmpty) {
      return _knownCities;
    }

    final url = ApiConfig.buildUrl(ApiConfig.search, {'q': query.trim()});
    final response = await _get(url);

    final data = json.decode(response.body);
    if (data is! List) {
      return [];
    }

    return data
        .whereType<Map<String, dynamic>>()
        .map((item) {
          final name = item['name']?.toString() ?? '';
          final country = item['country']?.toString() ?? '';
          if (country.isEmpty) {
            return name;
          }
          return '$name, $country';
        })
        .where((value) => value.trim().isNotEmpty)
        .toList();
  }

  String getIconUrl(String iconCode) {
    if (iconCode.startsWith('http://') || iconCode.startsWith('https://')) {
      return iconCode;
    }

    if (iconCode.startsWith('//')) {
      return 'https:$iconCode';
    }

    return 'https://openweathermap.org/img/wn/$iconCode@2x.png';
  }

  Future<Map<String, dynamic>> _getForecastPayload({
    required String query,
    required int days,
  }) async {
    final url = ApiConfig.buildUrl(ApiConfig.forecast, {
      'q': query,
      'days': days,
      'aqi': 'no',
      'alerts': 'no',
    });

    final response = await _get(url);
    final decoded = json.decode(response.body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    throw Exception('Invalid weather response format.');
  }

  Future<http.Response> _get(String url) async {
    try {
      final response = await _client
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return response;
      }

      final message = _extractErrorMessage(response.body);

      if (response.statusCode == 400 && message.contains('No location found')) {
        throw Exception('City not found');
      }

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Weather API key error: $message');
      }

      throw Exception('Failed to fetch weather data: $message');
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    } catch (error) {
      if (error is Exception) {
        rethrow;
      }
      throw Exception('Network error: $error');
    }
  }

  String _extractErrorMessage(String body) {
    try {
      final data = json.decode(body);
      if (data is Map<String, dynamic>) {
        final message = data['error']?['message']?.toString();
        if (message != null && message.isNotEmpty) {
          return message;
        }
      }
    } catch (_) {
      // ignore parse errors and use fallback message below.
    }
    return 'Unknown error.';
  }

  WeatherModel _mapCurrentWeather(Map<String, dynamic> payload) {
    final location = payload['location'] as Map<String, dynamic>? ?? {};
    final current = payload['current'] as Map<String, dynamic>? ?? {};

    final forecastDays =
        (payload['forecast']?['forecastday'] as List<dynamic>? ?? const []);
    final today = forecastDays.isNotEmpty
        ? forecastDays.first as Map<String, dynamic>
        : <String, dynamic>{};
    final day = today['day'] as Map<String, dynamic>? ?? {};
    final astro = today['astro'] as Map<String, dynamic>? ?? {};

    final date = DateTime.fromMillisecondsSinceEpoch(
      ((location['localtime_epoch'] as num?)?.toInt() ??
              DateTime.now().millisecondsSinceEpoch ~/ 1000) *
          1000,
    );

    return WeatherModel(
      cityName: location['name']?.toString() ?? 'Unknown',
      country: location['country']?.toString() ?? '--',
      temperature: (current['temp_c'] as num?)?.toDouble() ?? 0,
      feelsLike: (current['feelslike_c'] as num?)?.toDouble() ?? 0,
      humidity: (current['humidity'] as num?)?.toInt() ?? 0,
      windSpeed: ((current['wind_kph'] as num?)?.toDouble() ?? 0) / 3.6,
      windDegree: (current['wind_degree'] as num?)?.toInt() ?? 0,
      pressure: (current['pressure_mb'] as num?)?.round() ?? 0,
      description: current['condition']?['text']?.toString() ?? 'N/A',
      icon: current['condition']?['icon']?.toString() ?? '01d',
      mainCondition: current['condition']?['text']?.toString() ?? 'Clear',
      dateTime: date,
      tempMin: (day['mintemp_c'] as num?)?.toDouble(),
      tempMax: (day['maxtemp_c'] as num?)?.toDouble(),
      visibility: (((current['vis_km'] as num?)?.toDouble() ?? 0) * 1000)
          .round(),
      cloudiness: (current['cloud'] as num?)?.toInt(),
      uvIndex: (current['uv'] as num?)?.toDouble(),
      sunrise: _parseAstroTime(astro['sunrise']?.toString(), date),
      sunset: _parseAstroTime(astro['sunset']?.toString(), date),
    );
  }

  List<ForecastModel> _mapForecastSlots(Map<String, dynamic> payload) {
    final forecastDays =
        (payload['forecast']?['forecastday'] as List<dynamic>? ?? const []);

    final hourlyItems = <ForecastModel>[];
    for (final dayItem in forecastDays.whereType<Map<String, dynamic>>()) {
      final hours = dayItem['hour'] as List<dynamic>? ?? const [];
      for (var i = 0; i < hours.length; i += 3) {
        final hour = hours[i] as Map<String, dynamic>;
        final condition = hour['condition'] as Map<String, dynamic>? ?? {};

        hourlyItems.add(
          ForecastModel(
            dateTime: DateTime.fromMillisecondsSinceEpoch(
              ((hour['time_epoch'] as num?)?.toInt() ?? 0) * 1000,
            ),
            temperature: (hour['temp_c'] as num?)?.toDouble() ?? 0,
            description: condition['text']?.toString() ?? 'N/A',
            icon: condition['icon']?.toString() ?? '',
            tempMin: (hour['temp_c'] as num?)?.toDouble() ?? 0,
            tempMax: (hour['temp_c'] as num?)?.toDouble() ?? 0,
            humidity: (hour['humidity'] as num?)?.toInt() ?? 0,
            windSpeed: ((hour['wind_kph'] as num?)?.toDouble() ?? 0) / 3.6,
            precipitationProbability:
                ((hour['chance_of_rain'] as num?)?.toDouble() ?? 0) / 100,
          ),
        );
      }
    }

    return hourlyItems.take(40).toList();
  }

  List<HourlyWeatherModel> _mapHourlyForecast(
    Map<String, dynamic> payload,
    int hours,
  ) {
    final now = DateTime.now();
    final forecastDays =
        (payload['forecast']?['forecastday'] as List<dynamic>? ?? const []);

    final items = <HourlyWeatherModel>[];

    for (final dayItem in forecastDays.whereType<Map<String, dynamic>>()) {
      final dayHours = dayItem['hour'] as List<dynamic>? ?? const [];
      for (final entry in dayHours.whereType<Map<String, dynamic>>()) {
        final time = DateTime.fromMillisecondsSinceEpoch(
          ((entry['time_epoch'] as num?)?.toInt() ?? 0) * 1000,
        );

        if (time.isBefore(now)) {
          continue;
        }

        final condition = entry['condition'] as Map<String, dynamic>? ?? {};

        items.add(
          HourlyWeatherModel(
            dateTime: time,
            temperature: (entry['temp_c'] as num?)?.toDouble() ?? 0,
            icon: condition['icon']?.toString() ?? '',
            condition: condition['text']?.toString() ?? 'N/A',
            precipitationProbability:
                ((entry['chance_of_rain'] as num?)?.toDouble() ?? 0) / 100,
          ),
        );
      }
    }

    items.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return items.take(hours).toList();
  }

  DateTime? _parseAstroTime(String? value, DateTime date) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final match = RegExp(
      r'^(\d{1,2}):(\d{2})\s*(AM|PM)$',
      caseSensitive: false,
    ).firstMatch(value.trim());
    if (match == null) {
      return null;
    }

    var hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    final period = match.group(3)!.toUpperCase();

    if (period == 'PM' && hour != 12) {
      hour += 12;
    }

    if (period == 'AM' && hour == 12) {
      hour = 0;
    }

    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  void _assertApiKey() {
    if (apiKey.trim().isEmpty) {
      throw Exception(
        'Missing API key in .env file. Add WEATHER_API_KEY (or OPENWEATHER_API_KEY).',
      );
    }
  }

  WeatherModel _buildCurrentWeather({
    required String cityName,
    double? latitude,
    double? longitude,
  }) {
    final seed = cityName.hashCode.abs();
    final random = Random(seed);
    final now = DateTime.now();

    final condition = _conditionByIndex(seed % _conditions.length);
    final icon = _iconForCondition(condition, now.hour);

    final temp = 22 + random.nextInt(13) + random.nextDouble();
    final feelsLike = temp - 1 + random.nextDouble() * 2;
    final min = temp - (1 + random.nextDouble() * 2);
    final max = temp + (1 + random.nextDouble() * 2);

    final sunrise = DateTime(now.year, now.month, now.day, 5, 45);
    final sunset = DateTime(now.year, now.month, now.day, 18, 10);

    return WeatherModel(
      cityName: _titleCase(cityName),
      country: 'VN',
      temperature: temp,
      feelsLike: feelsLike,
      humidity: 55 + random.nextInt(35),
      windSpeed: 1 + random.nextDouble() * 7,
      windDegree: random.nextInt(360),
      pressure: 1000 + random.nextInt(30),
      description: _descriptionForCondition(condition),
      icon: icon,
      mainCondition: condition,
      dateTime: now,
      tempMin: min,
      tempMax: max,
      visibility: 4000 + random.nextInt(6000),
      cloudiness: random.nextInt(100),
      uvIndex: 1 + random.nextDouble() * 8,
      sunrise: sunrise,
      sunset: sunset,
    );
  }

  List<ForecastModel> _buildForecast(String cityName) {
    final seed = cityName.hashCode.abs();
    final random = Random(seed);
    final base = DateTime.now();

    return List<ForecastModel>.generate(40, (index) {
      final slotTime = base.add(Duration(hours: index * 3));
      final condition = _conditionByIndex((seed + index) % _conditions.length);
      final icon = _iconForCondition(condition, slotTime.hour);

      final baseTemp = 23 + sin(index / 3) * 4;
      final temperature = baseTemp + random.nextDouble() * 1.2;
      final min = temperature - (0.8 + random.nextDouble() * 1.5);
      final max = temperature + (0.8 + random.nextDouble() * 1.5);

      return ForecastModel(
        dateTime: slotTime,
        temperature: temperature,
        description: _descriptionForCondition(condition),
        icon: icon,
        tempMin: min,
        tempMax: max,
        humidity: 55 + random.nextInt(35),
        windSpeed: 1 + random.nextDouble() * 7,
        precipitationProbability: random.nextDouble(),
      );
    });
  }

  List<HourlyWeatherModel> _buildHourly(String cityName, int hours) {
    final seed = cityName.hashCode.abs();
    final random = Random(seed + 57);
    final now = DateTime.now();

    return List<HourlyWeatherModel>.generate(hours, (index) {
      final when = now.add(Duration(hours: index));
      final condition = _conditionByIndex((seed + index) % _conditions.length);
      final icon = _iconForCondition(condition, when.hour);

      return HourlyWeatherModel(
        dateTime: when,
        temperature: 22 + sin(index / 4) * 3 + random.nextDouble(),
        icon: icon,
        condition: condition,
        precipitationProbability: random.nextDouble(),
      );
    });
  }

  static const List<String> _conditions = [
    'Clear',
    'Clouds',
    'Rain',
    'Mist',
    'Thunderstorm',
  ];

  String _conditionByIndex(int index) =>
      _conditions[index % _conditions.length];

  String _descriptionForCondition(String condition) {
    switch (condition) {
      case 'Clear':
        return 'clear sky';
      case 'Clouds':
        return 'broken clouds';
      case 'Rain':
        return 'light rain';
      case 'Mist':
        return 'misty';
      case 'Thunderstorm':
        return 'thunderstorm';
      default:
        return 'unknown';
    }
  }

  String _iconForCondition(String condition, int hour) {
    final isNight = hour < 6 || hour >= 18;

    switch (condition) {
      case 'Clear':
        return isNight ? '01n' : '01d';
      case 'Clouds':
        return isNight ? '03n' : '03d';
      case 'Rain':
        return isNight ? '10n' : '10d';
      case 'Mist':
        return isNight ? '50n' : '50d';
      case 'Thunderstorm':
        return isNight ? '11n' : '11d';
      default:
        return isNight ? '01n' : '01d';
    }
  }

  String _normalize(String text) {
    return text.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
  }

  String _titleCase(String value) {
    return value
        .split(' ')
        .where((part) => part.trim().isNotEmpty)
        .map(
          (part) =>
              '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
        )
        .join(' ');
  }
}
