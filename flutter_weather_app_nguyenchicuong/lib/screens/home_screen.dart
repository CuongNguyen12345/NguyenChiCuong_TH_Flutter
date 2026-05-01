import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/forecast_model.dart';
import '../models/weather_model.dart';
import '../providers/weather_provider.dart';
import '../utils/constants.dart';
import '../utils/date_formatter.dart';
import '../widgets/current_weather_card.dart';
import '../widgets/daily_forecast_card.dart';
import '../widgets/error_widget.dart';
import '../widgets/hourly_forecast_list.dart';
import '../widgets/loading_shimmer.dart';
import '../widgets/weather_detail_item.dart';
import 'forecast_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherProvider>().fetchWeatherByLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, provider, child) {
        final backgroundGradient = provider.currentWeather == null
            ? const LinearGradient(
                colors: [Color(0xFFF5F7FA), Color(0xFFE4ECF5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : WeatherGradients.byCondition(provider.currentWeather!.mainCondition);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Weather App'),
            actions: [
              IconButton(
                icon: const Icon(Icons.calendar_month_rounded),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ForecastScreen()),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings_rounded),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
              ),
            ],
          ),
          body: Container(
            decoration: BoxDecoration(gradient: backgroundGradient),
            child: RefreshIndicator(
              onRefresh: provider.refreshWeather,
              child: _buildBody(provider),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            },
            child: const Icon(Icons.search_rounded),
          ),
        );
      },
    );
  }

  Widget _buildBody(WeatherProvider provider) {
    if (provider.state == WeatherState.loading && provider.currentWeather == null) {
      return const LoadingShimmer();
    }

    if (provider.state == WeatherState.error && provider.currentWeather == null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 100),
          ErrorWidgetCustom(
            message: provider.errorMessage,
            onRetry: provider.fetchWeatherByLocation,
          ),
        ],
      );
    }

    if (provider.currentWeather == null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 120),
          Center(child: Text('No weather data available yet.')),
        ],
      );
    }

    final weather = provider.currentWeather!;
    final dailyForecast = _dailyItems(provider.forecast);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 6),
        CurrentWeatherCard(weather: weather),
        _statusBar(provider),
        const SizedBox(height: 14),
        HourlyForecastList(forecasts: provider.hourlyForecast),
        const SizedBox(height: 18),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppDimensions.screenPadding),
          child: Text(
            'Daily Forecast (5-7 days)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.screenPadding),
          child: Column(
            children: dailyForecast
                .map((item) => DailyForecastCard(forecast: item))
                .toList(),
          ),
        ),
        const SizedBox(height: 12),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppDimensions.screenPadding),
          child: Text(
            'Weather Details',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.all(AppDimensions.screenPadding),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: WeatherDetailItem(
                      icon: Icons.water_drop_rounded,
                      label: 'Humidity',
                      value: '${weather.humidity}%',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: WeatherDetailItem(
                      icon: Icons.air_rounded,
                      label: 'Wind',
                      value: provider.windSpeedLabel(weather.windSpeed),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: WeatherDetailItem(
                      icon: Icons.compress_rounded,
                      label: 'Pressure',
                      value: '${weather.pressure} hPa',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: WeatherDetailItem(
                      icon: Icons.visibility_rounded,
                      label: 'Visibility',
                      value: '${((weather.visibility ?? 0) / 1000).toStringAsFixed(1)} km',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: WeatherDetailItem(
                      icon: Icons.wb_sunny_outlined,
                      label: 'UV Index',
                      value: weather.uvIndex?.toStringAsFixed(1) ?? '--',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: WeatherDetailItem(
                      icon: Icons.explore_rounded,
                      label: 'Wind Dir',
                      value: '${weather.windDegree}\u00B0',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: WeatherDetailItem(
                      icon: Icons.wb_twilight_rounded,
                      label: 'Sunrise',
                      value: weather.sunrise == null
                          ? '--'
                          : DateFormatter.hourLabel(
                              weather.sunrise!,
                              use24HourFormat: provider.use24HourFormat,
                            ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: WeatherDetailItem(
                      icon: Icons.nights_stay_rounded,
                      label: 'Sunset',
                      value: weather.sunset == null
                          ? '--'
                          : DateFormatter.hourLabel(
                              weather.sunset!,
                              use24HourFormat: provider.use24HourFormat,
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppDimensions.screenPadding),
          child: Text(
            'Air Quality',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 8),
        _airQualitySection(weather),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _statusBar(WeatherProvider provider) {
    final chips = <Widget>[];

    if (provider.isOffline) {
      chips.add(_chip('Offline', Colors.red.shade100, Colors.red.shade900));
    }

    if (provider.isUsingCachedData) {
      chips.add(_chip('Cached data', Colors.orange.shade100, Colors.orange.shade900));
    }

    if (provider.isDataOutdated) {
      chips.add(_chip('Outdated', Colors.grey.shade300, Colors.grey.shade900));
    }

    if (provider.lastUpdate != null) {
      chips.add(
        _chip(
          'Updated ${DateFormatter.hourLabel(provider.lastUpdate!, use24HourFormat: provider.use24HourFormat)}',
          Colors.blue.shade100,
          Colors.blue.shade900,
        ),
      );
    }

    if (chips.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.screenPadding),
      child: Wrap(spacing: 8, runSpacing: 8, children: chips),
    );
  }

  Widget _chip(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 12, color: fg, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _airQualitySection(WeatherModel weather) {
    final aqi = weather.usEpaAqi;
    final hasPollutants =
        weather.pm25 != null ||
        weather.pm10 != null ||
        weather.carbonMonoxide != null ||
        weather.nitrogenDioxide != null ||
        weather.ozone != null ||
        weather.sulfurDioxide != null;

    if (aqi == null && !hasPollutants) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: AppDimensions.screenPadding),
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(14),
            child: Text('Air quality data is not available for this location.'),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.screenPadding),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.air_rounded),
                  const SizedBox(width: 8),
                  Text(
                    'US EPA AQI: ${aqi ?? '--'}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(width: 8),
                  if (aqi != null) _levelBadge(aqi),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _aqiRecommendation(aqi),
                style: TextStyle(color: Colors.grey.shade700),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _pollutantChip('PM2.5', weather.pm25, 'ug/m3'),
                  _pollutantChip('PM10', weather.pm10, 'ug/m3'),
                  _pollutantChip('CO', weather.carbonMonoxide, 'ug/m3'),
                  _pollutantChip('NO2', weather.nitrogenDioxide, 'ug/m3'),
                  _pollutantChip('O3', weather.ozone, 'ug/m3'),
                  _pollutantChip('SO2', weather.sulfurDioxide, 'ug/m3'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pollutantChip(String label, double? value, String unit) {
    final text = value == null ? '--' : '${value.toStringAsFixed(1)} $unit';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade50,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$label: $text',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _levelBadge(int aqi) {
    final color = _aqiColor(aqi);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _aqiLabel(aqi),
        style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12),
      ),
    );
  }

  Color _aqiColor(int aqi) {
    switch (aqi) {
      case 1:
        return Colors.green.shade700;
      case 2:
        return Colors.amber.shade800;
      case 3:
        return Colors.orange.shade700;
      case 4:
        return Colors.red.shade700;
      case 5:
        return Colors.purple.shade700;
      case 6:
        return Colors.brown.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  String _aqiLabel(int aqi) {
    switch (aqi) {
      case 1:
        return 'Good';
      case 2:
        return 'Moderate';
      case 3:
        return 'Unhealthy (Sensitive)';
      case 4:
        return 'Unhealthy';
      case 5:
        return 'Very Unhealthy';
      case 6:
        return 'Hazardous';
      default:
        return 'Unknown';
    }
  }

  String _aqiRecommendation(int? aqi) {
    switch (aqi) {
      case 1:
        return 'Air quality is good. Outdoor activities are safe for most people.';
      case 2:
        return 'Air quality is acceptable. Sensitive people should monitor symptoms.';
      case 3:
        return 'Sensitive groups should reduce prolonged outdoor activity.';
      case 4:
        return 'Limit outdoor activity and consider wearing a mask if needed.';
      case 5:
        return 'Avoid prolonged outdoor exposure. Keep indoor air clean.';
      case 6:
        return 'Avoid outdoor activity. Follow local health advisories immediately.';
      default:
        return 'No health recommendation available.';
    }
  }

  List<ForecastModel> _dailyItems(List<ForecastModel> raw) {
    final grouped = <String, List<ForecastModel>>{};

    for (final item in raw) {
      final key = DateFormatter.shortDate(item.dateTime);
      grouped.putIfAbsent(key, () => []).add(item);
    }

    final result = <ForecastModel>[];
    for (final entry in grouped.entries) {
      final dayItems = entry.value;
      final avgTemp = dayItems.map((e) => e.temperature).reduce((a, b) => a + b) / dayItems.length;
      final minTemp = dayItems.map((e) => e.tempMin).reduce((a, b) => a < b ? a : b);
      final maxTemp = dayItems.map((e) => e.tempMax).reduce((a, b) => a > b ? a : b);
      final first = dayItems.first;

      result.add(
        ForecastModel(
          dateTime: first.dateTime,
          temperature: avgTemp,
          description: first.description,
          icon: first.icon,
          tempMin: minTemp,
          tempMax: maxTemp,
          humidity: first.humidity,
          windSpeed: first.windSpeed,
          precipitationProbability: dayItems
                  .map((e) => e.precipitationProbability)
                  .reduce((a, b) => a + b) /
              dayItems.length,
        ),
      );
    }

    return result.take(7).toList();
  }
}
