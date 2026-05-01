import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  ApiConfig._();

  static const String baseUrl = 'https://api.weatherapi.com/v1';
  static const String currentWeather = '/current.json';
  static const String forecast = '/forecast.json';
  static const String search = '/search.json';

  static String get apiKey {
    if (dotenv.isInitialized) {
      final dotenvWeather = dotenv.env['WEATHER_API_KEY'] ?? '';
      if (dotenvWeather.isNotEmpty) {
        return dotenvWeather;
      }

      final dotenvOpenWeather = dotenv.env['OPENWEATHER_API_KEY'] ?? '';
      if (dotenvOpenWeather.isNotEmpty) {
        return dotenvOpenWeather;
      }

      final envWeather =
          const String.fromEnvironment('WEATHER_API_KEY', defaultValue: '');
      if (envWeather.isNotEmpty) {
        return envWeather;
      }

      return const String.fromEnvironment(
        'OPENWEATHER_API_KEY',
        defaultValue: '',
      );
    }

    final weatherKey =
        const String.fromEnvironment('WEATHER_API_KEY', defaultValue: '');
    if (weatherKey.isNotEmpty) {
      return weatherKey;
    }
    return const String.fromEnvironment('OPENWEATHER_API_KEY', defaultValue: '');
  }

  static String buildUrl(String endpoint, Map<String, dynamic> params) {
    final query = <String, String>{
      ...params.map((key, value) => MapEntry(key, value.toString())),
    };

    if (apiKey.isNotEmpty) {
      query['key'] = apiKey;
    }

    final uri = Uri.parse('$baseUrl$endpoint');
    return uri.replace(queryParameters: query).toString();
  }
}
