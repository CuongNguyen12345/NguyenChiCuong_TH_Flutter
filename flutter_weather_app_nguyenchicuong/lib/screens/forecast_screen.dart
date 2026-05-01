import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/forecast_model.dart';
import '../providers/weather_provider.dart';
import '../utils/constants.dart';
import '../utils/date_formatter.dart';
import '../widgets/daily_forecast_card.dart';

class ForecastScreen extends StatelessWidget {
  const ForecastScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('5-7 Day Forecast')),
      body: Consumer<WeatherProvider>(
        builder: (context, provider, child) {
          final daily = _dailyItems(provider.forecast);
          if (daily.isEmpty) {
            return const Center(child: Text('No forecast data.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppDimensions.screenPadding),
            itemBuilder: (context, index) => DailyForecastCard(forecast: daily[index]),
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemCount: daily.length,
          );
        },
      ),
    );
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
