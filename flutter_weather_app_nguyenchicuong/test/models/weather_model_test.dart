import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_weather_app_nguyenchicuong/models/weather_model.dart';

void main() {
  group('WeatherModel Tests', () {
    test('Parse weather JSON correctly', () {
      final json = {
        'name': 'Ho Chi Minh City',
        'sys': {'country': 'VN', 'sunrise': 1714449600, 'sunset': 1714494300},
        'main': {
          'temp': 25.0,
          'feels_like': 27.0,
          'humidity': 80,
          'pressure': 1008,
          'temp_min': 24.0,
          'temp_max': 29.0,
        },
        'wind': {'speed': 3.5, 'deg': 140},
        'weather': [
          {'description': 'light rain', 'icon': '10d', 'main': 'Rain'}
        ],
        'dt': 1714471200,
        'visibility': 5000,
        'clouds': {'all': 90},
        'uvi': 4.2,
      };

      final weather = WeatherModel.fromJson(json);

      expect(weather.temperature, 25.0);
      expect(weather.cityName, 'Ho Chi Minh City');
      expect(weather.mainCondition, 'Rain');
      expect(weather.humidity, 80);
      expect(weather.windDegree, 140);
    });
  });
}
