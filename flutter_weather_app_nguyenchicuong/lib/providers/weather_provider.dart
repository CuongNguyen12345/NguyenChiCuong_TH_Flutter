import 'dart:async';

import 'package:flutter/material.dart';

import '../models/forecast_model.dart';
import '../models/hourly_weather_model.dart';
import '../models/weather_model.dart';
import '../services/connectivity_service.dart';
import '../services/location_service.dart';
import '../services/storage_service.dart';
import '../services/weather_service.dart';
import '../utils/constants.dart';

enum WeatherState { initial, loading, loaded, error }

class WeatherProvider extends ChangeNotifier {
  final WeatherService _weatherService;
  final LocationService _locationService;
  final StorageService _storageService;
  final ConnectivityService _connectivityService;

  WeatherModel? _currentWeather;
  List<ForecastModel> _forecast = [];
  List<HourlyWeatherModel> _hourlyForecast = [];
  WeatherState _state = WeatherState.initial;
  String _errorMessage = '';
  bool _isOffline = false;
  bool _isUsingCachedData = false;
  DateTime? _lastUpdate;

  List<String> _favoriteCities = [];
  List<String> _searchHistory = [];

  TemperatureUnit _temperatureUnit = TemperatureUnit.celsius;
  WindSpeedUnit _windSpeedUnit = WindSpeedUnit.metersPerSecond;
  bool _use24HourFormat = true;
  String _languageCode = 'en';

  StreamSubscription<bool>? _connectivitySubscription;

  WeatherProvider(
    this._weatherService,
    this._locationService,
    this._storageService,
    this._connectivityService,
  ) {
    _initialize();
  }

  WeatherModel? get currentWeather => _currentWeather;
  List<ForecastModel> get forecast => _forecast;
  List<HourlyWeatherModel> get hourlyForecast => _hourlyForecast;
  WeatherState get state => _state;
  String get errorMessage => _errorMessage;
  bool get isOffline => _isOffline;
  bool get isUsingCachedData => _isUsingCachedData;
  DateTime? get lastUpdate => _lastUpdate;
  bool get isDataOutdated {
    if (_lastUpdate == null) {
      return false;
    }
    return DateTime.now().difference(_lastUpdate!) > const Duration(minutes: 30);
  }
  List<String> get favoriteCities => _favoriteCities;
  List<String> get searchHistory => _searchHistory;
  TemperatureUnit get temperatureUnit => _temperatureUnit;
  WindSpeedUnit get windSpeedUnit => _windSpeedUnit;
  bool get use24HourFormat => _use24HourFormat;
  String get languageCode => _languageCode;

  Future<void> _initialize() async {
    _favoriteCities = await _storageService.getFavoriteCities();
    _searchHistory = await _storageService.getSearchHistory();
    _temperatureUnit = await _storageService.getTemperatureUnit();
    _windSpeedUnit = await _storageService.getWindSpeedUnit();
    _use24HourFormat = await _storageService.getUse24HourFormat();
    _languageCode = await _storageService.getLanguageCode();
    _lastUpdate = await _storageService.getLastUpdate();

    _connectivitySubscription = _connectivityService.connectionStream.listen((online) {
      _isOffline = !online;
      notifyListeners();
    });

    await loadCachedWeather();
  }

  Future<void> fetchWeatherByCity(String cityName) async {
    if (cityName.trim().isEmpty) {
      _setError('Please enter a city name.');
      return;
    }

    _state = WeatherState.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final online = await _connectivityService.isOnline();
      _isOffline = !online;

      if (!online) {
        final loaded = await loadCachedWeather();
        if (!loaded) {
          throw Exception('No internet connection and no cached weather available.');
        }
        _isUsingCachedData = true;
        return;
      }

      _currentWeather = await _weatherService.getCurrentWeatherByCity(cityName);
      _forecast = await _weatherService.getForecast(cityName);
      _hourlyForecast = await _weatherService.getHourlyForecast(cityName);

      await _storageService.saveWeatherData(_currentWeather!);
      await _storageService.saveForecastData(_forecast);
      await _storageService.saveHourlyData(_hourlyForecast);

      _lastUpdate = DateTime.now();
      _isUsingCachedData = false;
      _state = WeatherState.loaded;

      await _addSearchHistory(cityName);
    } catch (error) {
      final loaded = await loadCachedWeather();
      if (!loaded) {
        _setError(error.toString());
      } else {
        _isUsingCachedData = true;
      }
    }

    notifyListeners();
  }

  Future<void> fetchWeatherByLocation() async {
    _state = WeatherState.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final online = await _connectivityService.isOnline();
      _isOffline = !online;

      if (!online) {
        final loaded = await loadCachedWeather();
        if (!loaded) {
          throw Exception('No internet connection and no cached weather available.');
        }
        _isUsingCachedData = true;
        return;
      }

      final position = await _locationService.getCurrentLocation();
      final weather = await _weatherService.getCurrentWeatherByCoordinates(
        position.latitude,
        position.longitude,
      );

      final cityFromGeocoding = await _locationService.getCityName(
        position.latitude,
        position.longitude,
      );

      _currentWeather = weather;
      final cityForForecast = cityFromGeocoding == 'Unknown' ? weather.cityName : cityFromGeocoding;
      _forecast = await _weatherService.getForecast(cityForForecast);
      _hourlyForecast = await _weatherService.getHourlyForecast(cityForForecast);

      await _storageService.saveWeatherData(_currentWeather!);
      await _storageService.saveForecastData(_forecast);
      await _storageService.saveHourlyData(_hourlyForecast);

      _lastUpdate = DateTime.now();
      _isUsingCachedData = false;
      _state = WeatherState.loaded;
    } catch (error) {
      final loaded = await loadCachedWeather();
      if (!loaded) {
        _setError(error.toString());
      } else {
        _isUsingCachedData = true;
      }
    }

    notifyListeners();
  }

  Future<bool> loadCachedWeather() async {
    final cachedWeather = await _storageService.getCachedWeather();
    if (cachedWeather == null) {
      return false;
    }

    _currentWeather = cachedWeather;
    _forecast = await _storageService.getCachedForecast();
    _hourlyForecast = await _storageService.getCachedHourly();
    _lastUpdate = await _storageService.getLastUpdate();

    _state = WeatherState.loaded;
    _errorMessage = '';
    _isUsingCachedData = true;
    notifyListeners();

    return true;
  }

  Future<void> refreshWeather() async {
    if (_currentWeather != null) {
      await fetchWeatherByCity(_currentWeather!.cityName);
      return;
    }
    await fetchWeatherByLocation();
  }

  Future<List<String>> searchCities(String query) async {
    return _weatherService.searchCities(query);
  }

  bool isFavorite(String cityName) {
    return _favoriteCities.any((city) => city.toLowerCase() == cityName.toLowerCase());
  }

  Future<void> toggleFavorite(String cityName) async {
    if (isFavorite(cityName)) {
      _favoriteCities.removeWhere((city) => city.toLowerCase() == cityName.toLowerCase());
    } else {
      if (_favoriteCities.length >= 5) {
        _setError('You can only save up to 5 favorite cities.');
        return;
      }
      _favoriteCities.add(cityName);
    }

    await _storageService.saveFavoriteCities(_favoriteCities);
    notifyListeners();
  }

  Future<void> removeSearchItem(String cityName) async {
    _searchHistory.removeWhere((city) => city.toLowerCase() == cityName.toLowerCase());
    await _storageService.saveSearchHistory(_searchHistory);
    notifyListeners();
  }

  Future<void> clearSearchHistory() async {
    _searchHistory = [];
    await _storageService.saveSearchHistory(_searchHistory);
    notifyListeners();
  }

  Future<void> setTemperatureUnit(TemperatureUnit unit) async {
    _temperatureUnit = unit;
    await _storageService.saveTemperatureUnit(unit);
    notifyListeners();
  }

  Future<void> setWindSpeedUnit(WindSpeedUnit unit) async {
    _windSpeedUnit = unit;
    await _storageService.saveWindSpeedUnit(unit);
    notifyListeners();
  }

  Future<void> setUse24HourFormat(bool value) async {
    _use24HourFormat = value;
    await _storageService.saveUse24HourFormat(value);
    notifyListeners();
  }

  Future<void> setLanguageCode(String code) async {
    _languageCode = code;
    await _storageService.saveLanguageCode(code);
    notifyListeners();
  }

  double displayTemperature(double celsius) {
    if (_temperatureUnit == TemperatureUnit.celsius) {
      return celsius;
    }
    return (celsius * 9 / 5) + 32;
  }

  String temperatureLabel(double celsius) {
    final value = displayTemperature(celsius).round();
    final symbol = _temperatureUnit == TemperatureUnit.celsius ? 'C' : 'F';
    return '$value\u00B0$symbol';
  }

  double displayWindSpeed(double metersPerSecond) {
    switch (_windSpeedUnit) {
      case WindSpeedUnit.metersPerSecond:
        return metersPerSecond;
      case WindSpeedUnit.kilometersPerHour:
        return metersPerSecond * 3.6;
      case WindSpeedUnit.milesPerHour:
        return metersPerSecond * 2.23694;
    }
  }

  String windSpeedLabel(double metersPerSecond) {
    final value = displayWindSpeed(metersPerSecond).toStringAsFixed(1);
    switch (_windSpeedUnit) {
      case WindSpeedUnit.metersPerSecond:
        return '$value m/s';
      case WindSpeedUnit.kilometersPerHour:
        return '$value km/h';
      case WindSpeedUnit.milesPerHour:
        return '$value mph';
    }
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  Future<void> _addSearchHistory(String cityName) async {
    final formatted = cityName.trim();
    _searchHistory.removeWhere((item) => item.toLowerCase() == formatted.toLowerCase());
    _searchHistory.insert(0, formatted);

    if (_searchHistory.length > 10) {
      _searchHistory = _searchHistory.take(10).toList();
    }

    await _storageService.saveSearchHistory(_searchHistory);
  }

  void _setError(String message) {
    _state = WeatherState.error;
    _errorMessage = message.replaceFirst('Exception: ', '');
    notifyListeners();
  }
}
