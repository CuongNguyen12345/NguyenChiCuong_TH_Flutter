import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_weather_app_nguyenchicuong/services/weather_service.dart';

void main() {
  group('WeatherService Tests', () {
    final weatherService = WeatherService(useMockData: true);

    test('Handle invalid city gracefully', () async {
      expect(
        () => weatherService.getCurrentWeatherByCity('InvalidCity'),
        throwsException,
      );
    });

    test('Return forecast and hourly data', () async {
      final forecast = await weatherService.getForecast('Ho Chi Minh City');
      final hourly = await weatherService.getHourlyForecast('Ho Chi Minh City');

      expect(forecast, isNotEmpty);
      expect(hourly.length, 24);
    });
  });
}
