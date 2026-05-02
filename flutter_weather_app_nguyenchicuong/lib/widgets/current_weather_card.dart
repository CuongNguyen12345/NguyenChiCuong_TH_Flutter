import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/weather_model.dart';
import '../providers/weather_provider.dart';
import '../utils/constants.dart';
import '../utils/date_formatter.dart';
import '../utils/weather_icons.dart';

class CurrentWeatherCard extends StatelessWidget {
  final WeatherModel weather;

  const CurrentWeatherCard({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WeatherProvider>();
    final iconUrl = weather.icon.startsWith('http://') ||
            weather.icon.startsWith('https://')
        ? weather.icon
        : weather.icon.startsWith('//')
            ? 'https:${weather.icon}'
            : 'https://openweathermap.org/img/wn/${weather.icon}@4x.png';

    return Container(
      margin: const EdgeInsets.all(AppDimensions.screenPadding),
      padding: const EdgeInsets.all(AppDimensions.screenPadding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        gradient: WeatherGradients.byCondition(weather.mainCondition),
        boxShadow: const [
          BoxShadow(
            blurRadius: AppDimensions.cardElevation * 2,
            offset: Offset(0, 5),
            color: Colors.black26,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${weather.cityName}, ${weather.country}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      DateFormatter.fullDate(weather.dateTime),
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormatter.hourLabel(
                        weather.dateTime,
                        use24HourFormat: provider.use24HourFormat,
                      ),
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              CachedNetworkImage(
                imageUrl: iconUrl,
                width: 90,
                height: 90,
                errorWidget: (context, url, error) => Icon(
                  WeatherIcons.iconForCondition(weather.mainCondition),
                  color: Colors.white,
                  size: 56,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            provider.temperatureLabel(weather.temperature),
            style: const TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 0.95,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            weather.description.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Feels like ${provider.temperatureLabel(weather.feelsLike)}',
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
