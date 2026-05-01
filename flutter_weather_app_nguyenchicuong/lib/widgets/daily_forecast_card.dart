import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/forecast_model.dart';
import '../providers/weather_provider.dart';
import '../utils/date_formatter.dart';
import '../utils/weather_icons.dart';

class DailyForecastCard extends StatelessWidget {
  final ForecastModel forecast;

  const DailyForecastCard({super.key, required this.forecast});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WeatherProvider>();

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            SizedBox(
              width: 70,
              child: Text(
                DateFormatter.dayLabel(forecast.dateTime),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  Icon(WeatherIcons.iconForCondition(forecast.description)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      forecast.description,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text('${(forecast.precipitationProbability * 100).round()}%'),
            const SizedBox(width: 12),
            Text(
              '${provider.temperatureLabel(forecast.tempMax)} / ${provider.temperatureLabel(forecast.tempMin)}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
