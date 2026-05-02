# flutter_weather_app_nguyenchicuong

Weather application for Lab 4 with full architecture and required screens/features.

Note: API integration is intentionally left in mock mode (`WeatherService(useMockData: true)`) so real API calls can be plugged in later.

## Features

- Current weather display
  - Temperature, feels-like, condition icon, city/country, date
- Weather details
  - Humidity, wind speed + direction, pressure, visibility, UV index, sunrise/sunset
- Forecast
  - Hourly forecast (next 24 hours)
  - Daily forecast summary (next 5-7 days)
- Air quality
  - US EPA AQI level
  - Pollutant levels (PM2.5, PM10, CO, NO2, O3, SO2)
  - Health recommendation by AQI level
- Search and location
  - Search by city
  - Automatic location weather (with permission handling)
  - Manual city selection
- Favorites and history
  - Favorite cities (up to 5)
  - Recent searches
- Offline support
  - Cache current weather + forecast + hourly data
  - Shows cached/outdated indicator when offline
- Settings
  - Temperature unit (C/F)
  - Wind speed unit (m/s, km/h, mph)
  - 12/24h format
  - Dark mode toggle
  - Language preference (stored)
- UX states
  - Loading state
  - Error state with retry
  - Pull-to-refresh
  - Dynamic UI gradients based on weather condition

## Project Structure

```text
lib/
  main.dart
  models/
    weather_model.dart
    forecast_model.dart
    location_model.dart
    hourly_weather_model.dart
  services/
    weather_service.dart
    location_service.dart
    storage_service.dart
    connectivity_service.dart
  providers/
    weather_provider.dart
    location_provider.dart
  screens/
    home_screen.dart
    search_screen.dart
    forecast_screen.dart
    settings_screen.dart
  widgets/
    current_weather_card.dart
    hourly_forecast_list.dart
    daily_forecast_card.dart
    weather_detail_item.dart
    loading_shimmer.dart
    error_widget.dart
  utils/
    constants.dart
    weather_icons.dart
    date_formatter.dart
  config/
    api_config.dart
```

## API Setup

1. Get a free API key from OpenWeatherMap.
2. Copy `.env.example` to `.env`.
3. Add your API key to `.env`:

```env
OPENWEATHER_API_KEY=your_actual_key_here
WEATHER_API_KEY=your_backup_api_key_here
```

4. Integrate real HTTP logic in `lib/services/weather_service.dart` by replacing mock branches where `useMockData` is checked.

## How To Run

```bash
flutter pub get
flutter run
```

## Technologies Used

- Flutter
- Provider
- HTTP (prepared for integration)
- Geolocator + Geocoding
- Shared Preferences
- Connectivity Plus
- Intl
- Cached Network Image
- Flutter Dotenv

## Testing

```bash
flutter test
```

Included tests:
- JSON parsing for weather model
- Weather service error handling and forecast generation

## Known Limitations

- Real API HTTP calls are not wired yet (mock data mode is active).
- Language switching is preference-only in this version (UI strings not localized yet).
- No severe weather alert integration yet.

## Future Improvements

- OpenWeatherMap live integration
- API fallback strategy
- Weather alerts/notifications
- Weather map layers
- Home screen widgets

## Screenshots

Create and place images in a `screenshots/` folder for submission:
- clear/sunny
- rainy
- cloudy
- night
- search screen
- forecast screen
- error state
- loading state
