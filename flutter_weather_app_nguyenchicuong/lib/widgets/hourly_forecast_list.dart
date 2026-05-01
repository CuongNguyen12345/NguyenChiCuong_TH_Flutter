import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/hourly_weather_model.dart';
import '../providers/weather_provider.dart';
import '../utils/constants.dart';
import '../utils/date_formatter.dart';
import '../utils/weather_icons.dart';

class HourlyForecastList extends StatelessWidget {
  final List<HourlyWeatherModel> forecasts;

  const HourlyForecastList({super.key, required this.forecasts});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WeatherProvider>();

    if (forecasts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppDimensions.screenPadding),
          child: Text(
            'Hourly Forecast (24h)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 150,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.screenPadding),
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final item = forecasts[index];
              return Container(
                width: 95,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      DateFormatter.hourLabel(
                        item.dateTime,
                        use24HourFormat: provider.use24HourFormat,
                      ),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Icon(
                      WeatherIcons.iconForCondition(item.condition),
                      size: 30,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      provider.temperatureLabel(item.temperature),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(item.precipitationProbability * 100).round()}%',
                      style: const TextStyle(fontSize: 11, color: Colors.black54),
                    ),
                  ],
                ),
              );
            },
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemCount: forecasts.length,
          ),
        ),
      ],
    );
  }
}
