import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/forecast_model.dart';
import '../models/hourly_weather_model.dart';
import '../models/weather_model.dart';
import '../utils/constants.dart';

class StorageService {
  static const String _weatherKey = 'cached_weather';
  static const String _forecastKey = 'cached_forecast';
  static const String _hourlyKey = 'cached_hourly';
  static const String _lastUpdateKey = 'last_update';
  static const String _favoriteCitiesKey = 'favorite_cities';
  static const String _searchHistoryKey = 'search_history';

  static const String _temperatureUnitKey = 'temperature_unit';
  static const String _windUnitKey = 'wind_speed_unit';
  static const String _hourFormatKey = 'use_24_hour_format';
  static const String _languageKey = 'language_code';
  static const String _darkModeKey = 'is_dark_mode';

  Future<void> saveWeatherData(WeatherModel weather) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_weatherKey, json.encode(weather.toJson()));
    await prefs.setInt(_lastUpdateKey, DateTime.now().millisecondsSinceEpoch);
  }

  Future<WeatherModel?> getCachedWeather() async {
    final prefs = await SharedPreferences.getInstance();
    final weatherJson = prefs.getString(_weatherKey);
    if (weatherJson == null) {
      return null;
    }
    return WeatherModel.fromJson(json.decode(weatherJson) as Map<String, dynamic>);
  }

  Future<void> saveForecastData(List<ForecastModel> forecasts) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = forecasts.map((item) => item.toJson()).toList();
    await prefs.setString(_forecastKey, json.encode(payload));
  }

  Future<List<ForecastModel>> getCachedForecast() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_forecastKey);
    if (raw == null) {
      return [];
    }
    final list = json.decode(raw) as List<dynamic>;
    return list
        .map((item) => ForecastModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveHourlyData(List<HourlyWeatherModel> hourly) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = hourly.map((item) => item.toJson()).toList();
    await prefs.setString(_hourlyKey, json.encode(payload));
  }

  Future<List<HourlyWeatherModel>> getCachedHourly() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_hourlyKey);
    if (raw == null) {
      return [];
    }
    final list = json.decode(raw) as List<dynamic>;
    return list
        .map((item) => HourlyWeatherModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<bool> isCacheValid({Duration ttl = const Duration(minutes: 30)}) async {
    final prefs = await SharedPreferences.getInstance();
    final lastUpdate = prefs.getInt(_lastUpdateKey);
    if (lastUpdate == null) {
      return false;
    }
    final difference = DateTime.now().millisecondsSinceEpoch - lastUpdate;
    return difference < ttl.inMilliseconds;
  }

  Future<DateTime?> getLastUpdate() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getInt(_lastUpdateKey);
    if (value == null) {
      return null;
    }
    return DateTime.fromMillisecondsSinceEpoch(value);
  }

  Future<void> saveFavoriteCities(List<String> cities) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoriteCitiesKey, cities);
  }

  Future<List<String>> getFavoriteCities() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_favoriteCitiesKey) ?? [];
  }

  Future<void> saveSearchHistory(List<String> queries) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_searchHistoryKey, queries);
  }

  Future<List<String>> getSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_searchHistoryKey) ?? [];
  }

  Future<void> saveTemperatureUnit(TemperatureUnit unit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_temperatureUnitKey, unit.name);
  }

  Future<TemperatureUnit> getTemperatureUnit() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_temperatureUnitKey);
    if (value == null) {
      return TemperatureUnit.celsius;
    }
    return TemperatureUnit.values.firstWhere(
      (item) => item.name == value,
      orElse: () => TemperatureUnit.celsius,
    );
  }

  Future<void> saveWindSpeedUnit(WindSpeedUnit unit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_windUnitKey, unit.name);
  }

  Future<WindSpeedUnit> getWindSpeedUnit() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_windUnitKey);
    if (value == null) {
      return WindSpeedUnit.metersPerSecond;
    }
    return WindSpeedUnit.values.firstWhere(
      (item) => item.name == value,
      orElse: () => WindSpeedUnit.metersPerSecond,
    );
  }

  Future<void> saveUse24HourFormat(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hourFormatKey, value);
  }

  Future<bool> getUse24HourFormat() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hourFormatKey) ?? true;
  }

  Future<void> saveLanguageCode(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
  }

  Future<String> getLanguageCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? 'en';
  }

  Future<void> saveDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, value);
  }

  Future<bool> getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_darkModeKey) ?? false;
  }
}
